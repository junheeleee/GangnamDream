"""Exact three-scene source successor, separate from translation acceptance.

This module never changes runtime text. Its inverse is a comparison-only view
for immutable earlier contracts. An unbound product or receipt stage is closed.
"""
from __future__ import annotations

import contextlib
import contextvars
import copy
import hashlib
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRODUCT_PARENT = "7fc9002048a4c83401c497a0116d3688a44c152b"
PRODUCT_COMMIT = "d52287cec17ba55a6e4035e0566c06e6704a2cc2"
ARC_PATHS = tuple("content/events" + suffix + "/arc_events.json"
                  for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW"))
KO_PATH = ARC_PATHS[0]
RUNTIME_PATHS = ("autoloads/GameState.gd", "autoloads/DataRegistry.gd")
INVENTORY_PATH = "content/meta/release_content_inventory.json"
RATING_PATH = "docs/CONTENT_RATING_INVENTORY.md"
LEDGER_PATH = "content/meta/full_game_localization.json"
PRODUCT_PATHS = (*ARC_PATHS, *RUNTIME_PATHS, INVENTORY_PATH, RATING_PATH)
SOURCE_PATHS = (KO_PATH, *RUNTIME_PATHS)
EVENT_IDS = ("arc_jaehyuk_aftermath", "arc_daeun_later_echo", "arc_jaehyuk_04b_counter")
ADDED_TEXT_LEAVES = tuple((EVENT_IDS[0], ("choices", 3, key)) for key in ("text", "result_text"))
RAW_SHA256 = {'content/events/arc_events.json': ('4abc2a1e0b61ac4ba9d130aff5a47f696eea27dfdd841ec88f1f4449972768f6',
                                    'a99075a31a0e8a47cb3d04efe17e2fac41ea37f9de493cae04444d29a1279c99'),
 'content/events_en/arc_events.json': ('a598057e745ddef838e3cbd4c468f6c1bb25f5cb092514bb0b42c418471775fc',
                                       '863e4e948ec13b2a4d5edd8a28c1dadaeab82433520e41bf63870fca2267f30b'),
 'content/events_ja/arc_events.json': ('90170751c5f6e87ca38594e2d17f9560e30ed650cad1eb2daeb79bb281a30a82',
                                       'eca76302a36de547cb8aa3a3f09ac6fc05bccce915e80fe2052274410887e884'),
 'content/events_zh-CN/arc_events.json': ('cf430c7267a3bad35249505e3e958eada5822500b64fad74764c15c2f720df0e',
                                          'ed637e00b9362cc6617e0d3e864776b33aadf83242938c62f04b9c26d429e790'),
 'content/events_zh-TW/arc_events.json': ('8078010d7601695302a61d6864338d21041dc656610a6d94d1ccec02b7c8ecd5',
                                          '1a68415a994cb28e02cbdb60687f5ab32a95dc58ee5765131128a5aa51719e16'),
 'autoloads/GameState.gd': ('5076adf75b13920ae97ff9174945acf9c43fc80dec73cb356da44f314b7741d8',
                            '03ac214f4ad4fafe5f242c61df79eb89c09aca5b7a0a686a7c386df75a5ba978'),
 'autoloads/DataRegistry.gd': ('8887fd8a1c8becaef27e2638efea78218281786699546fda26695753d9978f7e',
                               '023b6a38566c874874dae234d379f1ff4f14d6b54f49cb4cbe607c10b5526225'),
 'content/meta/release_content_inventory.json': ('265dee057cf31eba566362c2003da98b229e3c93e15a631580f21d4a2d5e9694',
                                                 '66f3f64a7d646f700745659d4ec1d58e7c9238aebb08ff3385b4da04e95a6280'),
 'docs/CONTENT_RATING_INVENTORY.md': ('f7d43ddb4e7b6dc10d5462f7601a9b71bf1578c9aa5101802e384756f6e0a7d1',
                                      'c717d354608c125fd12a79ad36f93db6c5c79d0423e10235d980d282b1aa81cb')}
# Independently sealed changed-line coordinates and old/new hunk hashes.
# These reject even rehashed mutations of raw pins, including whitespace.
RAW_PATCHES = {'content/events/arc_events.json': (('replace', 1558, 1559, 1558, 1559,
                                     '8f4d07cbded9d2ec26952095ddd0fa20a4fc3627758c3f951d53db4e96d9f076',
                                     '77b10c05d8d7fbd5d12f20fb99ab42373fa8651e40992b2fa94ccd292e2022ef'),
                                    ('replace', 1578, 1579, 1578, 1579,
                                     '1f6f42ee736196b89fd68d2b932441a3addf1223025ae824d4dfdff9eef82464',
                                     '30c5c3201a6f7113f1b1d19a9f7b4232dcb2b9a645911ea904ae1c8685c6b759'),
                                    ('replace', 1631, 1632, 1631, 1632,
                                     '937a5c6c10139ffbb2143fb33c38be42b710b45fc140fad07dc3cd7b3a2520e6',
                                     '82b3fc8d94e28033f4543b2a06549d8cb4282fc9807835883d3153a413efc4b0'),
                                    ('replace', 3009, 3010, 3009, 3010,
                                     '7c23848c1349e300aa45b70704a9a6b12224c1450c7e03875c475d8aa2aa2128',
                                     '218340678cb941a4b4a4b7df6e1dcd9be88bf9ca1a5f7e1018035b1b9390fe33'),
                                    ('replace', 3012, 3013, 3012, 3013,
                                     'e3417586bf3dcb55e376943563973f0628deae3851595be8c8da82a8a715691b',
                                     'b462f6d53658d50035010a5e819939d749e125ad03878b04ee794fc8994ff8cf'),
                                    ('replace', 3017, 3018, 3017, 3018,
                                     'd64dd1017afdc3b23ff5404d109b8c75d1cff1e993ad4d134870c387af1ec10b',
                                     '1e69b3482bd7161fc59b0047d22404aefeda76408a3ed22ef06834b15ea74cde'),
                                    ('replace', 3021, 3022, 3021, 3022,
                                     '4f19c5c469775bb02ee9cf698778a19bad89459af9ad0c158c3be4eaa9777ba2',
                                     'f864588364ed0c555f6d50abbb31a54dcd686416d98a47e8882544233a176615'),
                                    ('replace', 3026, 3027, 3026, 3027,
                                     '93b844feee9588ff2f9aaaac6ed867f0243a231ecf8f9ca4e5430b156550d7ab',
                                     'fb2bb608eebb1265932297f8763631c9931e10ea200296a4f176b18ee88aafe2'),
                                    ('replace', 3031, 3032, 3031, 3032,
                                     '4a71097a3ddf624698f5ead5b47cd38128e2cee655ff54bcffe2f30bb088291b',
                                     '43f66466a23b8b4a7856e1117647e3a80c1095f94efd9f8bcd8d9947fcbd9bda'),
                                    ('replace', 3035, 3036, 3035, 3036,
                                     '819cd4606f800f8b91b86bbf10d28a5c89d95833ef7ba4714a4b10670d8b838c',
                                     'd18292c8816b814b88af3eef599c85a8d0d88b3fb4d4ca5476ea6d3af7e0c4bd'),
                                    ('replace', 3040, 3041, 3040, 3041,
                                     '4c2068ba83ed39e531b23c3dcb9dc5a483be539c5501264dd65e7da42cf82e9c',
                                     'f3fa6ee98cc7e19f7262ff18edffce7d7378258b16066d998dbcb3c75522da5f'),
                                    ('replace', 3045, 3046, 3045, 3046,
                                     'a63b68abe12d64ab716de90d90cce700d7823cd0da6d86632a05ef515d6b9487',
                                     'fbb86b52aa3d1de446da55ecc433848664a2a84491de0cf93a30827ae4e8f043'),
                                    ('insert', 3050, 3050, 3050, 3060,
                                     'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                     '7da6bd40e70d709c31a68777902bb3f948c263efa743029f6424d6d76cdc5786'),
                                    ('replace', 3073, 3074, 3083, 3084,
                                     '50941ee082441547ddb79924d63b354fb0eafff61daa89ec4821a5fd402063e9',
                                     '57402a3fb715527104c97c363cfe377580c6c1883cd5feac7325973535a09112'),
                                    ('replace', 3076, 3077, 3086, 3088,
                                     'fea76bad4fe0d85e743682e636e4a363549956db11c3e41ecd9a4763cb8ec2c5',
                                     '3c4a3401e351fc27069339c52027c2b5c5ef8a188f4fa40ff185a39ecd0df324'),
                                    ('replace', 3085, 3086, 3096, 3097,
                                     'aa18a858f77938e1b2312429948dcd686cf7b6228fe071f772eafdbdf12c2605',
                                     '77c512cce5c4a43523f3aa0f8d0367105d83b1c983afb7fee17859a1ddd6b9a9'),
                                    ('replace', 3088, 3089, 3099, 3100,
                                     'da7059a2f8e3ab4d5d53451598142a4a18e802d8152854a3aafd4fe84292c1ef',
                                     '0550a228d0429b6d2b5862d042fb0018676f36cedb767361d1ee5a378ec2211c')),
 'content/events_en/arc_events.json': (('replace', 469, 470, 469, 470,
                                        '24a7eec92da0afb7d7a721034d759b9193d946986815199ec2dbfb979f94b9c4',
                                        '7988e4ee7c70937b419b30b399d17c417f5b31819b699a759458753754470cef'),
                                       ('replace', 473, 474, 473, 474,
                                        '52a534ba469174793ea8f983434992fa8f9e7219ac176abdd60ac028258673e4',
                                        '7c6170f31fdc7bd8454f287342f3268a44fd5dd322dcd28d884ca310533ce9ec'),
                                       ('replace', 481, 482, 481, 482,
                                        '806e700ed924160ae13ce22370db5e6bdf2ad37309d91930fbd190b5ef60f1fb',
                                        '3417b26aa21edc9453c6cbe97df48b44805a7b6dd6110eef0bf2bbb62611735c'),
                                       ('replace', 942, 943, 942, 943,
                                        'e385ec07fe541b22c7cbf50ee7010eb8e5b7d52bb642a0df991de1bb219fec3c',
                                        'cbfc4e29ecf13bafb2079bd877d58f9b0c00423a1858592c0a0f1af0a0347d7f'),
                                       ('replace', 945, 947, 945, 947,
                                        'e687aa9a0b75e4f60719a40987176df6cdabdbaacea9cfc27f99bfb483769fc2',
                                        '55868a7edfec82899bbafe7b667f422c04f95b2bee5cb27cda882582283cd942'),
                                       ('replace', 949, 951, 949, 951,
                                        '9d0c90dc2c14a2029682eccef9be6bc7918c0e72767906d87cfa6cc2b5f72c95',
                                        'b2a33260025ddb74eb59ec728eac0dfe09afb017f98d340ebe46a2d502e4968e'),
                                       ('replace', 953, 954, 953, 954,
                                        '1bbea933623b71b3f9ce57cbfba5933d0ff463b3b73e5a6b987433f0ca7c9c30',
                                        '376f9d1e381733fcba3ccf7b17c311ddccd27fb83dd9ca80ba521bb1c42156fa'),
                                       ('insert', 955, 955, 955, 959,
                                        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                        '4421c311d7632899cfd3b1e95745d76714d9cf04beac2e571a718a7de489d21d'),
                                       ('replace', 961, 962, 965, 966,
                                        '9a0579e6008f8905f13926ab3f6ef9cba1d7e695800f6d9e0c0db509488a1a70',
                                        '5d0a4c1e0ebbf668b7a70c15ace57e6685be7f77be84e44952a2c4b9c032e477'),
                                       ('replace', 964, 966, 968, 970,
                                        '27622c1eb695d070d9d1c03b8497df5d7ab356754924ec4bfac2e8117d9717d8',
                                        '1f08f88b2b9c52ddb530919bd0a8150bfde80fedfcf1686baac1c4e477d14805'),
                                       ('replace', 968, 969, 972, 973,
                                        '8dedccfdc002b66852bcae5dbf0943bb6474781f5f1841ee022dcc8d3cfa42ea',
                                        '271d01bc4bb48c7fa70db8ba2d9163e772bdf44879260a1ce47498830429828b')),
 'content/events_ja/arc_events.json': (('insert', 258, 258, 258, 262,
                                        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                        '4b54ac466f458baa158216684e550f452546ce2554d5ec4347766e5998846835'),),
 'content/events_zh-CN/arc_events.json': (('replace', 162, 163, 162, 164,
                                           'e90ad45ad29e02282d7becfc444de0c63a0812dfcf568fc272c9f51fcfdea0a3',
                                           '7f9bb714cc96d19b425a6fce0382e9900bedf6c244fd4d1d36683c5a62415679'),),
 'content/events_zh-TW/arc_events.json': (('insert', 258, 258, 258, 262,
                                           'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                           '205a08774967af5fc0e352fdaf62ba210bd037d13dc0a2df8b3f2db80025ac46'),),
 'autoloads/GameState.gd': (('insert', 1851, 1851, 1851, 1897, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                             '8ad49a0415fc14be2e9c473045bf81e17c78d309da81edfcf5c2272d000083e2'),
                            ('insert', 1859, 1859, 1905, 1907, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                             '19cac3d776ae4e96cc20499025007ec3c033ddcd631f3ae76a928b0ed402c5e3')),
 'autoloads/DataRegistry.gd': (('replace', 182, 183, 182, 183, 'dd06659a8de9f5bcdee59be01181dc6a10a028ad79903955f7df9e7d63b6bc9f',
                                '49b86b36b141f3e93b93e7e577306cb4c4e49f8f1b8eb82125ce6a41e4f9b00c'),
                               ('replace', 193, 194, 193, 194, 'dd599877a0644649a9b54b43dad08979c8eea28df94a7052288e70be81766564',
                                'f8e50b6910623843464f0984cdfca407376b1e96702f20c5be3833a5c24cd9dd'),
                               ('insert', 195, 195, 195, 202, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                '8c186bf3a32b1aa7be73ccbb3e06091a78ab647666f70c12465e3f2b50498dff'),
                               ('insert', 756, 756, 763, 801, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                'e64bc4e20fd86635d8d581de6c30527079296341ef1b81f27f1d36defd23ef7f'),
                               ('replace', 764, 766, 809, 822, '2a56a61bbe972f50444b39c426c5f22adad126fa2ba89c0afeb1640d3d74fa63',
                                '449e24d7a07403f01f7f8f87af61011c89faba0ed86ff8be6bd14712dccbe61b'),
                               ('insert', 781, 781, 837, 844, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                'ba3001a86f09d9a96a65ac069539fadfced8a8d3113f0d4241db9e2588673b72'),
                               ('replace', 793, 794, 856, 858, 'da4cb72739dd5a64baaab38a30c6775490f3820bca14477036b64e232031b2f0',
                                '066ac5e2d501a14160711bd593580cc10b9ce6ad70a49706d78454e7d4fa5391'),
                               ('insert', 805, 805, 869, 871, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                'a0f63673770707acdfcc07dcfeffce2361a12ff8e6026940dc5e79905d84fc7a'),
                               ('replace', 824, 825, 890, 892, '98a999652ae5bd7e3ceae70237236a2d1c09d65fd3718c72b7705c9b90a1758e',
                                '7f99a0ee1c294a8579d0ab35f997fea5c936a965313fd9e62ece14ca4c7f1172'),
                               ('insert', 828, 828, 895, 901, 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                'b18544bc7396db9ae4c748bb512dc186a584990a50bf34fb67326808b637d4eb')),
 'content/meta/release_content_inventory.json': (('replace', 618, 619, 618, 619,
                                                  'a0f0c29fca839e6f08fc056215a59bb06511f77e46d8aaee82a9c254f76db3f8',
                                                  'e45ad99805a0f83c4b58b4fb33312a9cf052c784f4138e3ce8c5f207f307979d'),
                                                 ('replace', 660, 661, 660, 661,
                                                  '1398f4e2ad36316e86520638437a9e7792dc8b085c1a650f1a6cf932374ef0fc',
                                                  '90230330548a7ff17de7566f04f68f2feece775fd88102a90ecc8a50e16103a8'),
                                                 ('replace', 688, 689, 688, 689,
                                                  'd0aabbcad2fbd9c8207fc4ea3af74ba110fa644ab785742997f865dcdb0e7200',
                                                  'f1556e977b62806638ff6b6e9e4fd6b5d35d1e958795587468bff22a60e4330a')),
 'docs/CONTENT_RATING_INVENTORY.md': (('replace', 136, 139, 136, 139,
                                       '6f793ca9efccfaf3971e3ea480ca46bb22ec95834aa04db10b335aa7f648a9f2',
                                       'f1a4ce158a6959e4915210d5c7f89d4a9dc2ea6f4b6961a9134e32a6413be89b'),)}
PREDECESSOR_SOURCE_MANIFEST_SHA256 = "76557c1ba11ce4ef8f3a3b1ba80cc3b79f9cc8e5f1f6459db3a0c3fd92f73973"
RECEIPT_PARENT = "1817f87969165c73255f05a448f007318f54910d"
RECEIPT_COMMIT = "f16da92274058d1e391f695f178df01ba7454a61"
RECEIPT_RAW_SHA256 = {
    "content/events_ja/arc_events.json": (
        "eca76302a36de547cb8aa3a3f09ac6fc05bccce915e80fe2052274410887e884",
        "5e9d27828ed39c8b51be920c97018860f3efa778f0e2581ff688d200db235458"),
    "content/events_zh-CN/arc_events.json": (
        "ed637e00b9362cc6617e0d3e864776b33aadf83242938c62f04b9c26d429e790",
        "856936d9d1753f6c758804eac6686a588657c5862acd981f9c19cd72f5a3924c"),
    "content/events_zh-TW/arc_events.json": (
        "1a68415a994cb28e02cbdb60687f5ab32a95dc58ee5765131128a5aa51719e16",
        "f516faece5978d4c6b90e4e59b878fb23387a72a57b6a720de99b6c0cc7f8079"),
    LEDGER_PATH: ("821474ec3c178acf16a0c3a80b17ed5bb8d7c49b81e63512f86a7647283d9fdf",
                  "c687b60588d76875f80c4c2b4681b971ccd2b99cdb53e51774dc0f3145f18c0f"),
}
RECEIPT_BATCH_SHA256 = {
    "ja": "7724d1842b86b17a2408e7aec2345b52cc71cce2dd038ddddbd8b19e2642d7fe",
    "zh-CN": "3f298eef8c6e770dac1e799f8a7987c581e7a0cb2b9e7b502dc237c2336dc65b",
    "zh-TW": "010e3e364bf613ee694f76fc6f4c2e8e3cf7f9c1b36fcab11cd6427e7392457f",
}
RECEIPT_SOURCE_MANIFEST_SHA256 = "900b842779fda24e42d93fcc484c1ded47dae43bbe0a198919feee6a5c9b500c"
LOCALES = ("ja", "zh-CN", "zh-TW")
RECEIPT_PATHS = (*ARC_PATHS[2:], LEDGER_PATH)
# The following authored/accepted transition is separate from the immutable
# three-scene product and its42 receipts above. Unbound stages admit nothing.
PERSON_EVENT_ID = "arc_36_unexpected_hand_person_deal"
PERSON_PATHS = tuple(path.replace("arc_events.json", "arc_chapter_themes.json") for path in ARC_PATHS)
PERSON_KO_PATH = PERSON_PATHS[0]
PERSON_DIK_KEYS = ("daeun_divorced", "daeun_romance_started")
PERSON_EDITED_TEXT_LEAVES = tuple((PERSON_EVENT_ID, keys) for keys in (
    ("description",), ("choices", 0, "text"), ("choices", 0, "result_text"),
    ("choices", 1, "result_text")))
PERSON_ADDED_TEXT_LEAVES = tuple((PERSON_EVENT_ID, ("description_if_known", key))
                               for key in PERSON_DIK_KEYS)
PERSON_TEXT_LEAVES = (*PERSON_EDITED_TEXT_LEAVES, *PERSON_ADDED_TEXT_LEAVES)
PERSON_PRODUCT_PATHS = PERSON_PATHS
PERSON_PRODUCT_PARENT = "332ece024a4e7ce57dd91e9cb852ef8b45234c98"
PERSON_PRODUCT_COMMIT = "e459b1d02727e21679c25a35288b2ff39b628ac5"
PERSON_RAW_SHA256 = {'content/events/arc_chapter_themes.json': ('f1e40587bb4edad0e84aec9bc8a2493852742baf5d150cbe1c9854f6395ba068',
                                            'f91cfe36428eeace5b88668952e8eb1ca677f6151852f3d14e24d2118bdb6f6a'),
 'content/events_en/arc_chapter_themes.json': ('cd1d32537e0fe9c98c6c293c15846fd5a9dced415678158a2491f39d6a20c120',
                                               '31de3b24f02da2c9bc1ead6f3005df946b9885603f665aefcfb51d9569abb5c6'),
 'content/events_ja/arc_chapter_themes.json': ('2f775853f223ebc9a5c418603838fb01a19a845237f04b5ebe68b28d1873a0e6',
                                               'c0987ebba354d196d49588ac593d309281adc7a72b0843bff7ca59eca14b2ab1'),
 'content/events_zh-CN/arc_chapter_themes.json': ('b70b77595820517baafd5101a8df39e65535b7b616fff4b8e71ec52d68b058ff',
                                                  '1656cfa01aef3346fd9aa2ba5f52bd9c6bc59b4d7f84e3370ac4585269af27a5'),
 'content/events_zh-TW/arc_chapter_themes.json': ('9403b110d5b4aff9c2eb321e8fb7b87ac25af5bb11dd8da9fe32de4adc1d501e',
                                                  'c15124d8d763957a26eb95f914a39c34511b1634336e4bb7dc4bdb94b8954b04')}
PERSON_RAW_PATCHES = {'content/events/arc_chapter_themes.json': (('replace',
                                             348,
                                             349,
                                             348,
                                             353,
                                             '235f53903f7ac95967966b496d7451418f4b9641dac97fa07f44898d1899ec5a',
                                             '714526a99f27192aa9b93a2cae209c9a09d59f932a4b78106892a80beb54851b'),
                                            ('replace',
                                             351,
                                             352,
                                             355,
                                             356,
                                             '4595666814193662e3e475edf526968ebb982de993aaa528d8ff727896a5ee55',
                                             '8106f34b7dd7ed4ec74db31f6a3cf099051a23f33c6aa26f00e73ff3979e0544'),
                                            ('replace',
                                             354,
                                             355,
                                             358,
                                             359,
                                             '8832ddbbf7dea43cf8708be60f24ae0ab78fc5b8b2e89793fedda8c816408ee1',
                                             '5565fba71f58fd89aeb3c9700240c27f57e1585bbfa1ae937a56c16e0b9efcd5'),
                                            ('replace',
                                             360,
                                             361,
                                             364,
                                             365,
                                             '874b52442944b85dea5cac4f1ea1ca7ea7f362993b67dd5213f9ca856fd3fbb3',
                                             'cf50a3a546f892fe160ccd917944553fdfd88408ed757eac806b3063dd29bfbc')),
 'content/events_en/arc_chapter_themes.json': (('replace',
                                                113,
                                                114,
                                                113,
                                                118,
                                                'ffa439ac1997d6c5369eddab9de6971b9fd1b2dad57e79c0a2b271026aeba6e0',
                                                'ef94b09f5e4de282254200277992638f8ea8c664f3730e4acd97fa8b6b1cfd4b'),
                                               ('replace',
                                                116,
                                                118,
                                                120,
                                                122,
                                                'b34a1ec9b37a77becaf0401ed131edf0feab9c801d43b354d8c6c03bde98cabe',
                                                'd66193e56729a64890a4ad6f862a072e8f26febd284691ee881799be4979d48a'),
                                               ('replace',
                                                121,
                                                122,
                                                125,
                                                126,
                                                'a7965116a2b612ed12e7109df760f3431c67f19712951194aa508a6e07e6782f',
                                                'a4cddc0fd0fa087e1112c769eb870ee1859d23777eb2720401161794cd64bbd9')),
 'content/events_ja/arc_chapter_themes.json': (('insert',
                                                190,
                                                190,
                                                190,
                                                194,
                                                'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                                '363f4eb82738942db56dce61bae3fe08e25da472d34f0aff1efd44d5b2bcfda1'),),
 'content/events_zh-CN/arc_chapter_themes.json': (('insert',
                                                   190,
                                                   190,
                                                   190,
                                                   194,
                                                   'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                                   '35e84cb153ea6f41fbddea661cfa75cc65a974f00339506e5d6a8fe345d9a3d9'),),
 'content/events_zh-TW/arc_chapter_themes.json': (('insert',
                                                   190,
                                                   190,
                                                   190,
                                                   194,
                                                   'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                                                   'c33d991bcc3a4b97f50bd6c749a7e97f7e3905c7a144bacc4c5422337810e538'),)}
PERSON_RECEIPT_PATHS = (*PERSON_PATHS[2:], LEDGER_PATH)
PERSON_RECEIPT_PARENT = "53a8737e911eb9f321c5e84a06d798a95597a76b"
PERSON_RECEIPT_COMMIT = "01846e8a69a146cfd23865aaad83fd76d6c7a83c"
PERSON_RECEIPT_RAW_SHA256 = {
    "content/events_ja/arc_chapter_themes.json": (
        "c0987ebba354d196d49588ac593d309281adc7a72b0843bff7ca59eca14b2ab1",
        "6ccb5ced67aa95cedc7d1fe0580e78dc8660ebdd245a2e2f88a46612fd881e6f"),
    "content/events_zh-CN/arc_chapter_themes.json": (
        "1656cfa01aef3346fd9aa2ba5f52bd9c6bc59b4d7f84e3370ac4585269af27a5",
        "3ce8ee7a0085353dcfde29f8e5d9df874f22a81514d4c3d58602a3f8c840b07f"),
    "content/events_zh-TW/arc_chapter_themes.json": (
        "c15124d8d763957a26eb95f914a39c34511b1634336e4bb7dc4bdb94b8954b04",
        "9ba764405279738ffd34c596d034aa599f96614e6bb42e0909ff10f170c4bd1e"),
    "content/meta/full_game_localization.json": (
        "c687b60588d76875f80c4c2b4681b971ccd2b99cdb53e51774dc0f3145f18c0f",
        "30f095de89a1d00e436147c57606f644dfd2a4b99f13cc2bc432749bdc0a996d"),
}
PERSON_RECEIPT_BATCH_SHA256 = {
    "ja": "8c1388ccec38a1d4dfc5b6fd5aa5f2f7ed855f0bdab32edaa2b2739e090b30a4",
    "zh-CN": "78e153e5f323b5f8e9853763eeedd509b62ebb6d78c1ea8d631a4dd9b80f60fb",
    "zh-TW": "c9de4e695f265baaeb353308c12367f94e10aac732f9786ccfde5b4e44a6be40",
}
PERSON_RECEIPT_SOURCE_MANIFEST_SHA256 = "a23c35a674df1932d1299735cde17260914a60c09a00e7617fe61c1fb5f93545"
PROSE_SELECTORS = (
    ("arc_midgame", "arc_year_one_mark", (
        ("description",),
        *(("description_memory_if_known", key) for key in (
            "m4_housing_priority_runway", "m4_housing_priority_privacy", "m4_housing_priority_time")),
        *(("choices", index, key) for index in (0, 1) for key in ("text", "result_text")))),
    ("arc_year_close", "arc_year2_close", (
        ("description",),
        *(("description_if_known", key) for key in (
            "y2_lease_renewed_one_year", "y2_lease_renewed_six_months", "y2_lease_move_out_scheduled",
            "year1_resolve", "year1_numb", "jaehyuk_stood_up", "chose_money_over_father", "crossed_line")),
        *(("choices", index, key) for index in (0, 1, 2) for key in ("text", "result_text")))),
    *(("arc_hyunsu", eid, (("title",), ("description",),
        ("description_if_known", "crossed_line"), ("description_if_known", "called_hyunsu_first"),
        ("choices", 1, "result_text"))) for eid in ("hyunsu_year5_call", "hyunsu_year5_call_father_passed")),
    ("arc_daeun_extension", "arc_daeun_year5_apart", (("description",),)),
    ("arc_daeun_extension", "arc_daeun_year5_ending", (("description",),
        *(("description_if_known", key) for key in ("daeun_married", "daeun_year4_close", "daeun_romance_started")))),
    *(("arc_chapter_themes", eid, (("description_memory_if_known",
        "arc_y4_missed_cost_seen&arc_y4_missed_cost_repaired_person"),))
        for eid in ("arc_y4_body_witness", "arc_y4_body_witness_hyunsu")),
)
PROSE_TEXT_LEAVES = tuple((eid, keys) for _name, eid, paths in PROSE_SELECTORS for keys in paths)
PROSE_NAMES = tuple(dict.fromkeys(name for name, _eid, _keys in PROSE_SELECTORS))
PROSE_PATHS = tuple("content/events" + suffix + "/" + name + ".json"
                    for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW") for name in PROSE_NAMES)
PROSE_KO_PATHS = PROSE_PATHS[:5]
PROSE_PRODUCT_PATHS = PROSE_PATHS[:10]
PROSE_RECEIPT_PATHS = (*PROSE_PATHS[10:], LEDGER_PATH)
PROSE_PRODUCT_PARENT = '629452e7650bdfb9f20fc547c7d4696481cf239b'
PROSE_PRODUCT_COMMIT = '8510be2210e3bb0715f9f8131d0bc9ac61379b46'
PROSE_RAW_SHA256 = {'content/events/arc_chapter_themes.json': ('f91cfe36428eeace5b88668952e8eb1ca677f6151852f3d14e24d2118bdb6f6a',
                                            '5d5f59092ee46e4c890ad561a9636680351f5f3388a7b60771e227455011a00e'),
 'content/events/arc_daeun_extension.json': ('73368ac994c998c32ba07b7e04453bcc703993287773cb657f624b53984e3934',
                                             'a8b8a729f55129def68361d71e212fb763399d939a1e04039b737e6915817b39'),
 'content/events/arc_hyunsu.json': ('2449594b27187c761db5d94784c5caa0b57c61fa6eb1bdc3e619fc62971a49ca',
                                    'a093d3c4f7fc1a6b673e0ca309321bd917881d9dad5bc83e863df7ca40fbb025'),
 'content/events/arc_midgame.json': ('b6fba397214aa8eaf2356e8fd5f70937add3451a8c3256759edf0c98d214b4d6',
                                     'db1874fca6073b1aeba546448f37630311adb3b2f4b03c556c5c3739dfc46a41'),
 'content/events/arc_year_close.json': ('7e30ee4323fa363331ae6cd0f4426eae175b482871dc229f654701be39ff1503',
                                        '62a97419d8e2fa0b3f0ef0e91da58b68bfabfa965fc058c22119d9ebb59c5c35'),
 'content/events_en/arc_chapter_themes.json': ('31de3b24f02da2c9bc1ead6f3005df946b9885603f665aefcfb51d9569abb5c6',
                                               '132fb945b8ae01981186f03137bb391394f67ce7e1983ebb8ade5ce36e902b11'),
 'content/events_en/arc_daeun_extension.json': ('3940f61e24f23f82a33572bc3e8aaa0dca18f42e501163fb2fac7aae4bc03f08',
                                                'e681709a594ab3be167bb7fece69f5ca8f4a286a7ba43723ce8f56045687f112'),
 'content/events_en/arc_hyunsu.json': ('3df4481d5e00fd578019d99dbb23e58821a27c665e4ffd7e1ec6db8b47611069',
                                       'bd5f6895a8b41fc5c4fc6ae27eab89145d95ecfe9aec981fff1903022e032ed4'),
 'content/events_en/arc_midgame.json': ('860e4692ea4f4513a86ca345d3c389c1ea74f644dc01643278a541faf51de6fe',
                                        '964bff4c15d39beb9de58d2bbd5081264373967113846142bdb9d97bb53d0d28'),
 'content/events_en/arc_year_close.json': ('671ba0020d4dd9a74d5d4fcd86b73b4d883fb9301ea947d771f2146ea1499806',
                                           '1d38ea243fb22bcf1ffc83be42068652488e04e555e7b7e0115f7a283a1e2ef2')}
PROSE_RAW_PATCHES = {'content/events/arc_chapter_themes.json': (('replace',
                                             1072,
                                             1073,
                                             1072,
                                             1073,
                                             '34024686001e44c8056db5511326fb94b2a11872bdc513554433414cd0ab614d',
                                             '151b0c2153b2cf5b96fd444008767949f90468df718ec4187778e6c629dbe3d2'),
                                            ('replace',
                                             1182,
                                             1183,
                                             1182,
                                             1183,
                                             '1c70cfb59969b98042e657a515c44049f2a846d4ec6cddf0411db588d1ce097d',
                                             'a0f24a7d592e7a417b2c0fd9be67040c3fcfe9f74e499a411045652c5a03e748')),
 'content/events/arc_daeun_extension.json': (('replace',
                                              220,
                                              221,
                                              220,
                                              221,
                                              '7fe59468bd321a54411e29acc90a1358c315a7b4bbe6f2c814c6a294f5702e6f',
                                              '63e5611c32a50cdf0111674775017c79c38d335c137c4d691e1661ffa0b7cd90'),
                                             ('replace',
                                              258,
                                              261,
                                              258,
                                              261,
                                              '3d63a497768a9c7ab0fd048d48935cea27f6be6b6680310d8b4bce77f804d1d2',
                                              '9a975ffcc5fe5cee3cfa151811d55812a12d84138edb53e0fa15583e59ed820e'),
                                             ('replace',
                                              281,
                                              282,
                                              281,
                                              282,
                                              '5140717e8cdc39aba9c9fba21a594cf812d5af7b69f7ed6cd2da6efab289ece4',
                                              'a781b872b2afc812989e645ec158abdaedd78400faa4fab4dfa598fbe6528d66')),
 'content/events/arc_hyunsu.json': (('replace',
                                     486,
                                     487,
                                     486,
                                     487,
                                     'beb237def71f4fc5f3116ad1e77732166d20a87523519262686b11b95a49ed03',
                                     'c730375f8354bb965fd1915e655c7210ed87bf586a6d62445db23c3c74618c97'),
                                    ('replace',
                                     505,
                                     506,
                                     505,
                                     506,
                                     '0d775e58bdec640720bdb748d401a8f12ba14c58d0d37de6f1b80d6b970a3731',
                                     '52ad26965358df4172549ce4d6a4d26d1ec9abb3ffa08d931148b12aaa4887f9'),
                                    ('replace',
                                     507,
                                     509,
                                     507,
                                     509,
                                     'e4d4021df84bab43e8d0dd69b812c13c7de85fe222fedd1ab1eb6c5a13ff52de',
                                     '323ea380b40009738f1b4b908597a9c470d51c988b809143069360234cd03330'),
                                    ('replace',
                                     529,
                                     530,
                                     529,
                                     530,
                                     'cbee57b22cdebdf8083bc6436358b0ffdec9bfbe94ac3caa829cc892bd6db869',
                                     '89cc4d62ab19053b72e3ac0bd1052acb5446f6218b89616af3e8e324bb231ce6'),
                                    ('replace',
                                     535,
                                     536,
                                     535,
                                     536,
                                     'beb237def71f4fc5f3116ad1e77732166d20a87523519262686b11b95a49ed03',
                                     'c730375f8354bb965fd1915e655c7210ed87bf586a6d62445db23c3c74618c97'),
                                    ('replace',
                                     554,
                                     555,
                                     554,
                                     555,
                                     'ab1bc82613464478a63c9a59521d49855816401a7f5be9482bd79f5055e8a1a4',
                                     '6287c078de2a4aaab44b9d15f32e58307423fa02e5d6546b026c712eaf40db90'),
                                    ('replace',
                                     556,
                                     558,
                                     556,
                                     558,
                                     'e4d4021df84bab43e8d0dd69b812c13c7de85fe222fedd1ab1eb6c5a13ff52de',
                                     '323ea380b40009738f1b4b908597a9c470d51c988b809143069360234cd03330'),
                                    ('replace',
                                     578,
                                     579,
                                     578,
                                     579,
                                     'cbee57b22cdebdf8083bc6436358b0ffdec9bfbe94ac3caa829cc892bd6db869',
                                     '89cc4d62ab19053b72e3ac0bd1052acb5446f6218b89616af3e8e324bb231ce6')),
 'content/events/arc_midgame.json': (('replace',
                                      2451,
                                      2452,
                                      2451,
                                      2452,
                                      'b1a2cd42fc7c2667c0102329fb7494241527edc0e510a90585df6e12d8524be9',
                                      '9e144fa75794c1d4ac34c20550af791707061353b6a8087420fb36c45f136c8a'),
                                     ('replace',
                                      2453,
                                      2456,
                                      2453,
                                      2456,
                                      '93fd171ac83e37ed485faa2035300b1cb59abed9446f9898df92fc9d04f88b41',
                                      '1f969dd41b1c5e9b43c10a80699f0942078785b0dd9968e24f8f79c76d9867d2'),
                                     ('replace',
                                      2469,
                                      2470,
                                      2469,
                                      2470,
                                      '92762baf7083e9fe6b9b98ee105b24b7d2067923d0ca25c78f23481053660720',
                                      'a9e8c9f15e4e5c5f6ec77c2db7c23c3e98451799f9236efd52e9d19ff20e7af5'),
                                     ('replace',
                                      2479,
                                      2480,
                                      2479,
                                      2480,
                                      '5c392a3113c409a075332e84e90d11ce8fa2c1ddb3433dc9d6c1115e138d0e4a',
                                      'a3b0235402a97d012bbd39b8219c17cbe21ae360edbd0146db5bf8a2cd440dc0'),
                                     ('replace',
                                      2482,
                                      2483,
                                      2482,
                                      2483,
                                      'a1fd3f84c8873fed90ad0c0834527f0968076fb88a8f9580f3d75ba938920428',
                                      '15e16be923480b5a1ef81627d37e69c56d45e190949e9fa0d35fc48ad17f8b20'),
                                     ('replace',
                                      2490,
                                      2491,
                                      2490,
                                      2491,
                                      'c6948494109dbd43caae2c9aa7e00c3a7eae399f78be3da3c7a2e24fee603361',
                                      '3bd930774ad5ddb65012b695b2376b7ea2fa8e85bdb4139881677633051d4d96')),
 'content/events/arc_year_close.json': (('replace',
                                         104,
                                         105,
                                         104,
                                         105,
                                         'cc000b81c584ffb90de2d85623c0d1f1e2f726d57e36fe625399dac3b9142e47',
                                         '46a61feef8a83e4131fe354d7a55015e55072ea4d88e36299be3c2e9068deeb9'),
                                        ('replace',
                                         106,
                                         114,
                                         106,
                                         114,
                                         '39c35c09fc5fbdaf3707efc4fc2f89ba4c3f6a566a4c7efaf213165668fcdd4b',
                                         'eb8be092c6919b926a94b5484ed1d7e892a514429b5e4c3a4d7c0f9abdb0cad6'),
                                        ('replace',
                                         117,
                                         118,
                                         117,
                                         118,
                                         '8051f989bfea23ab976b8ab5f95d76e2320e8a96574d3313d07ef57e84d401cd',
                                         '2a8fcaa7d36847fc8a44eb19f1d74491b97546ed949e76eea453b4e1dde6dd76'),
                                        ('replace',
                                         125,
                                         126,
                                         125,
                                         126,
                                         'c22a0f5c01869590f59c20a44a20745351a63cea4ecd72caace3eed134ddbcb3',
                                         '052ee042686f9686bfe55c40dabd29fcfa2b8c5d6875fa5c4d53eaa0925f6ddd'),
                                        ('replace',
                                         128,
                                         129,
                                         128,
                                         129,
                                         '8a4fbd686cb028df6e865c7bb3eab677cceef0ea30c1f27f6da7f58610d63f26',
                                         '1277bd94bb2f3b0437bc7ff2c34ce76b20924c39fea2e7c212d3116e92087099'),
                                        ('replace',
                                         136,
                                         137,
                                         136,
                                         137,
                                         '19e8b2560217e44f2454d7292e6509e3ae373809d68c37b8e5887faf8722db79',
                                         '2e4262f90e96711462415fcc2197092dd8c27280ae91c307bf82de3a5356cab8'),
                                        ('replace',
                                         139,
                                         140,
                                         139,
                                         140,
                                         'cb1ec106ff0c164e3150049fc35c9916703513695b6501d816600e813524bc84',
                                         '768cd37e187d9d6a556aed8d45931afbd6693c734b3fe27469c23ed849555e04'),
                                        ('replace',
                                         144,
                                         145,
                                         144,
                                         145,
                                         '29b2331fbfe56ef8793f15f736ff29648634c43a74e6e31b22091f94a90491dd',
                                         '81d53fcb0f13c9a96d6578cd185d1d68fcbcc2ca1ec309fc8dae0ec1ba149108')),
 'content/events_en/arc_chapter_themes.json': (('replace',
                                                439,
                                                440,
                                                439,
                                                440,
                                                '83538b521ac548425c80a66a8660b6e9d48eb7ad511473df585cb7af8ad24355',
                                                'f1f5642d19ab454400a9bccafe6f864fd127db7b720003ebc1503093c34cbf54'),
                                               ('replace',
                                                487,
                                                488,
                                                487,
                                                488,
                                                '455f7c6ae6c1e07a091c0d05c0c8f66a8c29f182df699fcb1d8b5b487235e7e6',
                                                'de37125fc1d4234453f218bda837c4e6e8c67f26ce12f2b8aa22b4273abdccb7')),
 'content/events_en/arc_daeun_extension.json': (('replace',
                                                 59,
                                                 60,
                                                 59,
                                                 60,
                                                 'f12dd5dbf1c9dbf8dbc06f973d49d6c3d3ba1aa64bc33396b9c741f9fe6b587b',
                                                 '8e49dd7252f77b004edbeb32351a00ff11ba6a2c3c8c70edfe35b9eeb78b7b54'),
                                                ('replace',
                                                 71,
                                                 74,
                                                 71,
                                                 74,
                                                 '3c8ec9149e2988ed1d96987e09119b86a1ff384fbca2ccd904bd2b2240625045',
                                                 '5c6eb14828907f2d24606690c89e9cc476bba4d40d51f764c097115b7ba74730'),
                                                ('replace',
                                                 79,
                                                 80,
                                                 79,
                                                 80,
                                                 'f982e043a81cdf5a340a3e3be04a9d7cc8de88d48766a7a3065e254847851fc4',
                                                 'a1db0e579508be0a01af95f973292496a1e77aff87afe6f5952cef2e1fcb3ad5')),
 'content/events_en/arc_hyunsu.json': (('replace',
                                        202,
                                        204,
                                        202,
                                        204,
                                        '40dee0003748ae8b178307e70d4b1d30eddd95f2c64848100e5b7f22afc95134',
                                        'd2cd72cb26d25f651fb4b3bdd3a3146a8e258b9ee8c2a56d1b4e9049911b3737'),
                                       ('replace',
                                        205,
                                        207,
                                        205,
                                        207,
                                        'e4c926fae3f4091f7b7cbc107964f490be705271dd408b6eb1df7cc440db58e2',
                                        '27233099d73c8f983527e393b92ed800f72c343ebf653bb2e03b09eb2c95c34d'),
                                       ('replace',
                                        215,
                                        216,
                                        215,
                                        216,
                                        'dd36e0342f97a0b95b415d1a0ad938997a4377135bc7880b390dd02cc1e7ea0d',
                                        'f7c39414c42eea367cd4f71ed6f547a0f95d3830f3606ef4ec88f890f0ca09a6'),
                                       ('replace',
                                        221,
                                        223,
                                        221,
                                        223,
                                        '8662ef759c27909459240be3fe63365b4d6fb3b729c0dda834369a540cff0dd6',
                                        '6a3e65a8c3dd8f9abac4b6277f65b3874c3774bb9967c4a8c5d29072e15827b9'),
                                       ('replace',
                                        224,
                                        226,
                                        224,
                                        226,
                                        'e4c926fae3f4091f7b7cbc107964f490be705271dd408b6eb1df7cc440db58e2',
                                        '27233099d73c8f983527e393b92ed800f72c343ebf653bb2e03b09eb2c95c34d'),
                                       ('replace',
                                        234,
                                        235,
                                        234,
                                        235,
                                        'dd36e0342f97a0b95b415d1a0ad938997a4377135bc7880b390dd02cc1e7ea0d',
                                        'f7c39414c42eea367cd4f71ed6f547a0f95d3830f3606ef4ec88f890f0ca09a6')),
 'content/events_en/arc_midgame.json': (('replace',
                                         799,
                                         800,
                                         799,
                                         800,
                                         '672f3990578240a572d4d73bcf69b00a50f80a6067e6c19b9ddef38f623af596',
                                         'f2bb98018a25d0b9a4606a9fe217a003e9a234c7694892e971ca08bf84019bbc'),
                                        ('replace',
                                         801,
                                         804,
                                         801,
                                         804,
                                         '7fb787e54f08023a04ab2bbb50d3216f1736e6e5a3a50872879e63b4a466ce53',
                                         'a125c33aa10cb331ad1b7546fd5fe18934f0913003d14499e8a4d7fe1f7a0be1'),
                                        ('replace',
                                         807,
                                         809,
                                         807,
                                         809,
                                         '631770171e60821d9397a936de77c312d29808dd264abf187a542722d14efbda',
                                         '13941bc6dea176008e57c63d05f4a7b404ac98f38960d4b928e02debb5588087'),
                                        ('replace',
                                         811,
                                         813,
                                         811,
                                         813,
                                         'e9f13d812d12d114128eed146d468cc8973162eb6dd83c4ed2e7d5611d3dabd6',
                                         '44cd55c6d26e6b29bd40be5b52ad0cebd50d27e9912bc8dc55ee237c410d35a0')),
 'content/events_en/arc_year_close.json': (('replace',
                                            52,
                                            53,
                                            52,
                                            53,
                                            '247ca8651ab1f0b6ba01850adc0d109c0b4f5bacb4610f83726ac98429910813',
                                            'fb696b1805bf09edf01cfe1edba7082e1f87695a765295c5f276897ebcca8311'),
                                           ('replace',
                                            54,
                                            62,
                                            54,
                                            62,
                                            '6d2dd28455e2b18bac5ea2b3f87bf82a9f5e1130ad4ce8745e580383e4fdad92',
                                            '80a85c670155c1050c660699f6509b90c56886b2ea53ce36dbe2b6e5eb81126b'),
                                           ('replace',
                                            65,
                                            67,
                                            65,
                                            67,
                                            '62278195457b4724fac368e19ffa003e2210337e0b81a5800d8f96fdaf16146b',
                                            '121e990435c73a7a07d41c5ee87ccedeefe73b8cde8dca6128c1e9b1599e5f3f'),
                                           ('replace',
                                            69,
                                            71,
                                            69,
                                            71,
                                            '5394b929ed772868178d46a40f6b56b14af302f9ebe3ea42c6b3155c17d8579b',
                                            '8a723ff3e111b859924539426b9cca55fab2190b5020f161847fe8bbcfcab4f9'),
                                           ('replace',
                                            73,
                                            75,
                                            73,
                                            75,
                                            'effce79d010859d1a7789f77c0060bc70155bb10179a72562d94916e11585202',
                                            '3b91ed39a4a4ef0bfa8f25bf8b791b32add00986a0a0b02a3446eca51ee05c83'))}
PROSE_RECEIPT_PARENT = 'a88a54e34e7289b93be6a2135ffc962b4a1cb47c'
PROSE_RECEIPT_COMMIT = '2670b2b841baa3877b1e6a3b9db7b689fe4dc613'
PROSE_RECEIPT_RAW_SHA256 = {'content/events_ja/arc_chapter_themes.json': ('6ccb5ced67aa95cedc7d1fe0580e78dc8660ebdd245a2e2f88a46612fd881e6f',
                                               'd7a82c12adc665179511bd657ee51679017839b565dd9c397db3943d05ac3911'),
 'content/events_ja/arc_daeun_extension.json': ('b77dbac478759f1880fac8553161bb2eb55669c526255f46ff35dc0a49f08f32',
                                                '556fc02a81965ff38aca4fc81a057c1476cf5c158f5c5ccc38dae98888914aa4'),
 'content/events_ja/arc_hyunsu.json': ('852d611078d624ae8fd0c5f06cc7fe883ec83ba8a06c127cddf3cc0e8454c57f',
                                       'cfa2a09230a7186f23bc332793918913a018f80c100417874313789c6ba5a213'),
 'content/events_ja/arc_midgame.json': ('5b8113bfeb0946f40dcae3613a77fd3b55c7e7e645003443febac208657f16a9',
                                        'e07b0f4ae333ad4e197e6d4fcd12b9e3be6190785032402c182a7478054788eb'),
 'content/events_ja/arc_year_close.json': ('cfa15c6fefcd990ba2d75861572367c17c39aad7c038646c75be9a7d7b43c8ab',
                                           '0086ec261a2167444d587d1158b066bfd91e738da9d717ef344f25604a856b90'),
 'content/events_zh-CN/arc_chapter_themes.json': ('3ce8ee7a0085353dcfde29f8e5d9df874f22a81514d4c3d58602a3f8c840b07f',
                                                  'e969eab707f68bc1587ff4b86c62b5772325b6c466e87d36334a91a31aa3a9a3'),
 'content/events_zh-CN/arc_daeun_extension.json': ('2b55f978a9517d445092e09a478360cd2fa2341a6ef8958f9ac6b5265601b296',
                                                   'd440cc7f059844684e8c6382f5a20b0751d9b70da07c64376d58546b82c5fd4f'),
 'content/events_zh-CN/arc_hyunsu.json': ('92fb3f2f9fbd674d0d21d94441131336442fbd4a66f92baa9a473007c08a6832',
                                          '2ff6c73a1b82fc5df0c1eaa56d084a0c6a8a37f74807725cdbfaeb69d661d50c'),
 'content/events_zh-CN/arc_midgame.json': ('3ff592dff7564a9e408538619e337fd9ab1230f7a6b719994e0e92a278cef126',
                                           '89e36247f39ada6eda81d1b73f7468607359103d7505af08d93628b7d3656f49'),
 'content/events_zh-CN/arc_year_close.json': ('46eefc3f608a28066c88d20269c21df7b7f977fc0860cc143edf153f9cd572fd',
                                              '00739ce3ff7c73eae5306ac21e87636e244c2739657311be63e8f655a651a572'),
 'content/events_zh-TW/arc_chapter_themes.json': ('9ba764405279738ffd34c596d034aa599f96614e6bb42e0909ff10f170c4bd1e',
                                                  '7696e334aebf150e593a661f39ace7df0d19d8687086c61c59de26bc16942c64'),
 'content/events_zh-TW/arc_daeun_extension.json': ('b15bb1b702b8dbaba2c27116005a5f0796ffb1cf854776241060d07d3c6f4b5e',
                                                   '646bce45668bbc296412cd7bca17cc04dd204125ac6dabd3fab92523f6274e92'),
 'content/events_zh-TW/arc_hyunsu.json': ('39ea586335494400eda3f98a8dea909893d3b59a901ef253ce57d9db0554c064',
                                          '6e624e0f4d25a51d0b58420775ce2ee0e65ab08629e5236085e3c638a0a6ceed'),
 'content/events_zh-TW/arc_midgame.json': ('5ffbd340cb8219dac93cf8324f5b2aae20aa1ab80bcab39d96cce1011d3fa053',
                                           'cb3f4b3be26f3192ae97bd7f8374d174281f20a37243a4a5d3baed7d2e5c2ed8'),
 'content/events_zh-TW/arc_year_close.json': ('114e7a9ec3b4de35ee4c8947dcea2096206e351bd3391975590216c224d3a588',
                                              '520a1b2da8371cb78f0fedc86c606c2505dbad5c61c749d2970bf311ced3d958'),
 'content/meta/full_game_localization.json': ('30f095de89a1d00e436147c57606f644dfd2a4b99f13cc2bc432749bdc0a996d',
                                              '6d1d899109d7dccff02a1819312cc97622d99c3464e9104eb6692124a4487a16')}
PROSE_RECEIPT_CHANGED_LEAVES = {
    path: tuple((eid, keys) for name, eid, selectors in PROSE_SELECTORS
                if path.endswith("/" + name + ".json") for keys in selectors)
    for path in PROSE_PATHS[10:]
}
PROSE_RECEIPT_BATCH_SHA256 = {'ja': '219387374abf37c6551250e28b872cf5778fd8a49e384a3624239f0ea8b65587',
 'zh-CN': 'f18f49cc715805d0a83bcc30f0698500107f21b1b69dd085ea1a497aea442444',
 'zh-TW': '8d63e3a8e1d7db9851af27fa61fbc85efa24dd102073b95522733f23f3beb3a9'}
PROSE_RECEIPT_SOURCE_MANIFEST_SHA256 = '9025a17f96b308b22e232f246bf8b04589937ad0c19e911398e6b7c20ca59bf5'
# Separate factual fingerprint/report correction; no source or receipt change.
PROSE_METADATA_PARENT = 'ff8ed4452b150a1e8d2df1aa27c79da255d2a1ba'
PROSE_METADATA_COMMIT = '3fcd2f49f1fdb8ec4baf00cfcc3d4b9154ec974d'
PROSE_METADATA_PATHS = (INVENTORY_PATH, RATING_PATH)
PROSE_METADATA_FINGERPRINTS = (
    "774677165b00bebadf6b2208cc0a26e6fc7a956bcd2f668d72637e75c3f143b5",
    "c29603bb29735d6b371fa63cccd56c5106ee31312d8ab0bf3afa29145f3820ed",
)
PROSE_METADATA_RAW_SHA256 = {'content/meta/release_content_inventory.json': ('66f3f64a7d646f700745659d4ec1d58e7c9238aebb08ff3385b4da04e95a6280',
                                                 'c8fdcc865c5a5ab06f177db50e9a1d5449cd9377781574a00c5f599194d25648'),
 'docs/CONTENT_RATING_INVENTORY.md': ('c717d354608c125fd12a79ad36f93db6c5c79d0423e10235d980d282b1aa81cb',
                                      '42f9943dd0f785c98ff4d2447ffd9d1ef63a6b2fe0cf70f56e4323b910458124')}
PROSE_METADATA_RAW_PATCHES = {'content/meta/release_content_inventory.json': (('replace',
                                                  532,
                                                  533,
                                                  532,
                                                  533,
                                                  'a583f8ed315ba8f93fe7922f19f61a1f7c1d64cf654b27f28981491743021a34',
                                                  '7ec89abb5f3ec7e0499b808a7b4ff4d77baa1ff40579482959c33dd9b5c6f928'),),
 'docs/CONTENT_RATING_INVENTORY.md': (('replace',
                                       134,
                                       135,
                                       134,
                                       135,
                                       '53469357e79494fb880ff223e8a6da5a788b578379ed5cf460baef6ae325bd5b',
                                       '18410c7181b2321b4dc7b47bae68888556d50914f95b568c7eca07884125d959'),)}
# Ending-money facts: source5, optional exact EN repair, ledger1, metadata2.
# Earlier source and receipt endpoints above are never redefined.
ENDING_PATHS = tuple("content/endings" + suffix + ".json"
                     for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW"))
ENDING_KO_PATH = ENDING_PATHS[0]
ENDING_SELECTORS = (
    ("stable_success", ("cut_sangchul_network",)),
    ("orthodox_pinnacle", ("salary_raised", "salary_denied", "credit_asserted", "credit_recognized",
                          "jobswitch_reconnected", "declined_golf", "extreme_frugal", "frugal_quiet",
                          "skipped_staycation", "ignored_mystery_info", "orthodox_wavered")),
    ("unorthodox_legend", ("cafe_double_jackpot", "coin_second_win", "holdem_high_stakes_win",
                          "own_path_solidified", "investigating_gray_contact", "gray_tip_debt_paid")),
)
ENDING_TEXT_LEAVES = tuple((eid, keys) for eid, flags in ENDING_SELECTORS
                           for keys in (("description",), *(("description_if_known", flag) for flag in flags)))
ENDING_PRODUCT_PARENT = "d6c1394fbf2a93f21179d7b7f9967cf9680fe449"
ENDING_PRODUCT_COMMIT = "34bcb5eacd5e7bb8a97248e0a3e108dfbc65ef1b"
ENDING_RAW_SHA256 = {'content/endings.json': ('92fdbd1767de9b389e8a6416c9fba7f84260cf874e4f27d4f7ebcf964ab7e9a5',
                          '041112ff5354131e69b2a47aa947d97c0bab2615ba16c531389cd0552c3ee828'),
 'content/endings_en.json': ('8f9eb23d08089e8ca90fc80b22fdccfc70caf4374b519b362b97da986a4330d8',
                             '58b7bdfd65cc9b348562bb202f774b710044f37ddc3fae30187962df62b39a47'),
 'content/endings_ja.json': ('de27f165baefc6585a1125e85e5e402ce7bb612c23f1508cba075fcbacdb2ae7',
                             '25f402be24df62bbde4f2cc5d0f37ec4928d876628ef761e6542bbac31ab28db'),
 'content/endings_zh-CN.json': ('ca31a4300b1811f9799d4d93096483ad0ca0d62d921f5ad775c94a7c1b274898',
                                '2712456cc62020ebad510aa11d0c5987e039a8f97b206eb8e740fd35b08fb6ea'),
 'content/endings_zh-TW.json': ('511d191b67d1252aa306bc71acc53a6c47a97a725cc6cab072548bc98f86f546',
                                '1a8a86cb7340fc8a863f026878387b931059a4b4fc7ff7956605ffba3a278266')}
ENDING_RAW_PATCHES = {
    'content/endings.json': (
        ('replace', 120, 121, 120, 121, '9a901a872b8171247cefef1bf1a67b3c8647fb61e80886663f7c61914fd79da1', 'db8ea397fa16e15cee5642d788c6360d616d1b2a68df88f68bd4695dcdba3a0b'),
        ('replace', 122, 123, 122, 123, '80ecf9b0b322810dfaff14607e448eda2a48225a893c63ae1da7e00abe0c5e3f', '66e33c4cfe1d31a53c48c453da2862d2584835ba3dbfec5e262b53ad907ab23b'),
        ('replace', 306, 307, 306, 307, 'ab2135126f471a027825c58fe3fabba6c0ffe145c12b63b9d03abfca23376523', 'db76941711f5d0be3956fd9a59ab6fdedf5ea85180a155a39f3666b6e707f665'),
        ('replace', 309, 320, 309, 320, 'c868c136681f3ab35b9f6e2144cbb8006f771d9b38573d4e69956fd17e230769', '0c927e89906e1c209b48c35367f197a6ac339fab0c963d8a537ad1970417dff9'),
        ('replace', 356, 357, 356, 357, 'a401f5f70f927e798635b51db49f20b4027037d25bdfc2117a9dec169626deec', '4f0c6be5a0c2020c9b54714edfddddc2723a35e3ead1e3c43f48969692ec8439'),
        ('replace', 358, 364, 358, 364, '9eddf5e073906b50590055907eb3e98de3a3f0ceb6011bcf8ce6bebe17c79ce8', '51968ceab52bf5804c4f95159bea09d8c04432920e9bd30034965a9fddd48783'),
    ),
    'content/endings_en.json': (
        ('replace', 94, 95, 94, 95, 'c0c2f4e68fa3cd23258c6cfc12091614703d7cffe52e1be6617cb2b74ad92bd6', '945a8949cbc24547c589096a22371313a09ec4e9649ff7c659ce183d607e3b16'),
        ('replace', 96, 97, 96, 97, '4fcb8b5622e6999ef688e4ae3ae465e46b9fa67b99b9c123ea22abc238626859', '03d7db3aa68bef4dbe5320297d9b918fd685f31665f0b98781b91cb8db7e08c0'),
        ('replace', 235, 236, 235, 236, '00b721ebdfe1949b230bf4d33563004a42ec87a518c88427e78cf63618dc6a39', '1e8223749bf5991c79ac6ee655cf8fb9753b431beee6257fbf56ab8742c59fed'),
        ('replace', 237, 248, 237, 248, '0f5f69209705401f021b3c4f5c68149aa0298c8423673c2e565c8612601be79f', '7c188d64a45dd951830a838b1c1fa214c3f12d67370ba0b7b116c02889061701'),
        ('replace', 275, 276, 275, 276, 'e96f8fedd78efd596b82041bd891ed8ea59cec7cfa38302edc873decfdc8d589', '19ba4fe99d24cf14d5f99be019d096b4206ad87c7a745a06ed58e1e7744a4308'),
        ('replace', 277, 283, 277, 283, '4fe786343fadda6ebe901600b3e77d19cb19070c13cea3a4da13017e1003e496', 'cc2f12c7606c113b0a20b70996b041f218e943e337b7f68c5c2159a2d9b3f0ea'),
    ),
    'content/endings_ja.json': (
        ('replace', 96, 97, 96, 97, '5f64a42f5f5324bf1b6c9989c4fc987defeaa510a6bf01db0b0b3143cacdd091', '36f7c93575abc783d3257098e00562f31964116b7e47418151fc6188c7cb8dfc'),
        ('replace', 98, 99, 98, 99, '34b2221384ef728a4f54a0966bed32995ef9c046d0ddf9c32455edc01daba595', '7dad3927b2af88e26de6a98d7106cbeb3a2dc00083f1e73a686d314fdae3c1c4'),
        ('replace', 237, 238, 237, 238, 'd1334ff09d61ee4d55c0c324e4880b3cb7f57d5a086e30fc2387539bf7490d56', '76b39473790eb96a76554dcf7ec3717500475aa2ffc579f8bc7756c6ba9c053a'),
        ('replace', 239, 250, 239, 250, '98547ea1025f0a5de198aca247788b682ffae41df4883b42d2e8679ac29ba5f8', 'd9c0021c7e4176c0d857fd4518844831e7165d07700847abbdbeb2f83c03eb07'),
        ('replace', 277, 278, 277, 278, 'cd16c2c2017cbb1ea1a121b6565b4d47d5ccd72d06af9877e2b864b184f55cc8', 'a1ec8114b64d28923c8be95b6cac401b8e48d46d3d64928ef1785c1be40d9907'),
        ('replace', 279, 285, 279, 285, '9450289c2cd6c142df0e8976753dd508e26c67972bab0d8867a275c559cf829e', 'a5de3c63f0881acd675f0a6e171f6092cb8228ed60eba3b4cf4f4f7d36f4f260'),
    ),
    'content/endings_zh-CN.json': (
        ('replace', 42, 43, 42, 43, '6d17f8fec15911382201d24ee55cf6b30ca52ac03a9cb9c2d4fe212505ac7e75', '9375c961841d835712b0372b0622cdd95c526c15306565cedeb79fe04828fc22'),
        ('replace', 44, 45, 44, 45, '1ac00c3a318b1fe7cec3d02598aac96a80bb91744d7cab70a8fd448f1f650e42', 'c37865fad1a274ee9fa872a6f717ba6caf60a1da76417fd792c7211002eeeefc'),
        ('replace', 337, 338, 337, 338, 'f0890853648d8278dbcb7978418fb0129b47df9a84812f23c095dc353e660a9d', '8f0fd7a5b8c4072e494dfc69e219457a116ea6bbb916fb1a254400ef4014bbd6'),
        ('replace', 339, 350, 339, 350, '0955d902caed444b6b793e4aa9678527edbb1c6df3198d205cc0d901e565002f', 'af575e5299de8c92544b8a175b9b792da2e924f1fc1b2ddbfdee1d5ab7eab756'),
        ('replace', 363, 364, 363, 364, 'a28e5de8e48e8394a692d6a7a51226c11c42e206580955338681d25894330714', '716d7e8bee25c5a8771a85924acfa278eacdf2b1639ac4f8ff1deb37b81211f7'),
        ('replace', 365, 371, 365, 371, 'def7fd3cdc190090d88fc2673b7ffdf0f590ad568d4f23bf1b5811b9dc97c50c', 'b641037b680072984f340d1321d429ee8e720c2dcbbfb85b39b6db82c41e8166'),
    ),
    'content/endings_zh-TW.json': (
        ('replace', 64, 65, 64, 65, '1acf3f988b5c0d2f857480448d2dbd415c3aa88ddbd2463e5bf140338219c0b6', '4705f6fe5bd15f509563f80b569532d82e41b4bf523d37fb7171f65585a1599b'),
        ('replace', 66, 67, 66, 67, '52a75d2d9a3075e2aaca145c9322cb6b5df767724d13228b59ce8161291e7439', 'c6dca96d35fa9388d064868e4683c9545e19c4c33220bd10f6aab1e01be781ab'),
        ('replace', 337, 338, 337, 338, '43c0974ebd549dc168ff444f15ebda6f94a1e7bb2095d818d8edbcd674f745fc', '08e631d23021b4156312d88e79bab04c45529c0f076dae22c03f45bd95873f90'),
        ('replace', 339, 350, 339, 350, '8fc23bf925b2a3fba734024902304fb5bc7db55ed24022c1030e7f56cfb987a7', '8c7cfd2a12122fabf8d7b99d5709e8aa2cf8ca6f45b0dca220fe9282619ec4d9'),
        ('replace', 363, 364, 363, 364, 'e94166114f4fed3360c588ffee7c4399541782ee2d62f785ff97bb67bc326352', 'c88bf74e0791299c46c7ef51aa358d44b7cf2b49c5f8cd1fca5ec4b246699434'),
        ('replace', 365, 371, 365, 371, '505c94e1654a3d36e5ea0fd3be3f291e1635f62c1f8235657a289ca630176688', '584a5626ddc03be861506d86bf9dd678981e2ee61eb0ed430e2237ec216632e2'),
    ),
}
ENDING_REPAIR_PARENT = ENDING_PRODUCT_COMMIT
ENDING_REPAIR_COMMIT = '0356d316ffa7307724fad15e805b0ffdeb6d270f'
ENDING_REPAIR_PATHS = (ENDING_PATHS[1],)
ENDING_REPAIR_LEAVES = tuple((eid, keys) for eid, keys in ENDING_TEXT_LEAVES
                             if len(keys) == 2 and eid in ("stable_success", "orthodox_pinnacle"))
ENDING_REPAIR_RAW_SHA256 = {'content/endings_en.json': ('58b7bdfd65cc9b348562bb202f774b710044f37ddc3fae30187962df62b39a47', 'b9e49c321770d1b0f45f0e41449f6cd97038419859d2014bba09f7a67de935bf')}
ENDING_REPAIR_RAW_PATCHES = {'content/endings_en.json': (('replace', 96, 97, 96, 97, '03d7db3aa68bef4dbe5320297d9b918fd685f31665f0b98781b91cb8db7e08c0', 'ffdad34f6823de5171e3a1df8966b3d1bf6f883103632b56088bcdf713dcda82'), ('replace', 237, 248, 237, 248, '7c188d64a45dd951830a838b1c1fa214c3f12d67370ba0b7b116c02889061701', 'd7795ab62a233d0ba3401557c5d7020b007382347894bddf58a503618481a97b'))}
ENDING_RECEIPT_PARENT = "cb01c907f56d19521db448118d28a8db0b65e61f"
ENDING_RECEIPT_COMMIT = "c5c38269f23bc996e2212c4bb77be89b4ed90b53"
ENDING_RECEIPT_PATHS = (LEDGER_PATH,)
ENDING_RECEIPT_RAW_SHA256 = {
    LEDGER_PATH: ("6d1d899109d7dccff02a1819312cc97622d99c3464e9104eb6692124a4487a16",
                  "9c540d3b5b4dc1ac5d3f28cbe96e6467bb9e6074266e7c01931e23b8fe49d191"),
}
ENDING_RECEIPT_BATCH_SHA256 = {
    "ja": "026d5fff8cbc554638d2070b8e3dbf25960e9690004f56cdd3f7f3f1d73bee98",
    "zh-CN": "eb174cc1d334cb0c9c9e7df710034e70a65e017b5208cc672c4f9e73d219ee59",
    "zh-TW": "c93fcc0502280451fe4766ba3ad25dde32940e3839d78b3e6bb016b367cc0f1e",
}
ENDING_RECEIPT_SOURCE_MANIFEST_SHA256 = "63cafaf564ccd7201376f36b02da592ddff41a8c328e76ae139795da4d94b2be"
ENDING_METADATA_PARENT = 'c5c38269f23bc996e2212c4bb77be89b4ed90b53'
ENDING_METADATA_COMMIT = 'b7893e89be9331ec99cbfe3f116686b759e490d6'
ENDING_METADATA_PATHS = (INVENTORY_PATH, RATING_PATH)
ENDING_METADATA_FINGERPRINTS = ('1fd30dca3654f7b1f974a1822c98bbda82077d4063b4917bce755563a230c293', '5d7ffe209a97a17218a58f1a117f46bce80878fd927ad1772bc5d869e8504650')
ENDING_METADATA_RAW_SHA256 = {'content/meta/release_content_inventory.json': ('c8fdcc865c5a5ab06f177db50e9a1d5449cd9377781574a00c5f599194d25648',
                                                 '7ef8fbb45ba48afbd6509deaf3419d0cc6857e7abf046081724580a4234d0359'),
 'docs/CONTENT_RATING_INVENTORY.md': ('42f9943dd0f785c98ff4d2447ffd9d1ef63a6b2fe0cf70f56e4323b910458124',
                                      '912d38b3b002292e9eed9d7164b4bdbc1feb0393186d015a02ff20b8ca020187')}
ENDING_METADATA_RAW_PATCHES = {'content/meta/release_content_inventory.json': (('replace',
                                                  265,
                                                  266,
                                                  265,
                                                  266,
                                                  '9bc670bb88b7680d5248dc5645da83ab4c3d75f541069dec06eb8ca83e8437e4',
                                                  '18db4266d1bbeace29e8c685cb101c9151335015739d9d0bcfdd3ab4fbf449e6'),),
 'docs/CONTENT_RATING_INVENTORY.md': (('replace',
                                       125,
                                       126,
                                       125,
                                       126,
                                       'd37d7411dd5beb0aedb921ef20680b2cd87d95598b5ad67f52113dba77ace25f',
                                       '7785db6cd65eb800a9164e18a47704f710e285e24c58a308438e68fb120396f3'),)}
# The two first-win facts use separate source5/KO-notation1/receipt1 transitions.
# All five paths already belong to472; that earlier endpoint stays immutable.
FIRST_WIN_PATHS = tuple("content/events" + suffix + "/arc_midgame.json"
                        for suffix in ("", "_en", "_ja", "_zh-CN", "_zh-TW"))
FIRST_WIN_KO_PATH = FIRST_WIN_PATHS[0]
FIRST_WIN_EVENT_IDS = ("arc_first_real_win", "arc_first_real_win_father_passed")
FIRST_WIN_TEXT_LEAVES = tuple((eid, ("choices", 0, "result_text")) for eid in FIRST_WIN_EVENT_IDS)
FIRST_WIN_PRODUCT_PARENT = "5ec492da9a1007f6cc6b10c7ac1d22135e47b356"
FIRST_WIN_PRODUCT_COMMIT = '1dbdf12ffa09b7143af43a006828af5d78e52619'
FIRST_WIN_RAW_SHA256 = {'content/events/arc_midgame.json': ('db1874fca6073b1aeba546448f37630311adb3b2f4b03c556c5c3739dfc46a41',
                                     '4edc95d3001a7e6df8b73c946f53855510305a9a464dbc1b75c5d26d4b309262'),
 'content/events_en/arc_midgame.json': ('964bff4c15d39beb9de58d2bbd5081264373967113846142bdb9d97bb53d0d28',
                                        'b7237dda9c0d87a6cf8f8845775916e0b4ee3cbceb2dd0da2e847513baaa21da'),
 'content/events_ja/arc_midgame.json': ('e07b0f4ae333ad4e197e6d4fcd12b9e3be6190785032402c182a7478054788eb',
                                        '63ebbdf7b91f4185789e06f66d84adec204c05118b99d0d0379e69dea85a20ad'),
 'content/events_zh-CN/arc_midgame.json': ('89e36247f39ada6eda81d1b73f7468607359103d7505af08d93628b7d3656f49',
                                           '017d3161eb743cde8c660407b3684e1c1f0ee2e83b8d882f332c1e1c7a8a6514'),
 'content/events_zh-TW/arc_midgame.json': ('cb3f4b3be26f3192ae97bd7f8374d174281f20a37243a4a5d3baed7d2e5c2ed8',
                                           'dcc316943babc5293729c6bd07e20e25ca8e090975d4202a506b33d06e48a114')}
FIRST_WIN_RAW_PATCHES = {
    'content/events/arc_midgame.json': (
        ('replace', 344, 345, 344, 345, '58f365fe2d096fb6fb4763b8404cc556fbddc11fdba248a340c4f90a1ad4677d', 'f4c413096072d5af8587c658fc869d4db097da0514f718eaa3e74b55fcd76c75'),
        ('replace', 4290, 4291, 4290, 4291, '2a9568cca288f0ea8673f0b59f183159dcf7c87b0233f2ee4caa30f62e0bd55a', 'f4c413096072d5af8587c658fc869d4db097da0514f718eaa3e74b55fcd76c75'),
    ),
    'content/events_en/arc_midgame.json': (
        ('replace', 106, 107, 106, 107, 'c9da6c1602149a3e98d1941f43a958ff5b3433fb592981c101f4c2c4318e5de6', 'aff78f1bd17d92ba1de78291a4ccf20157303166a3afc3dbe740ab40199f722b'),
        ('replace', 1573, 1574, 1573, 1574, '6b188fbb8f60407a676e8f291f1f648ab11df11b39f22764209ed63c0bc01f1d', 'aff78f1bd17d92ba1de78291a4ccf20157303166a3afc3dbe740ab40199f722b'),
    ),
    'content/events_ja/arc_midgame.json': (
        ('replace', 752, 753, 752, 753, 'c4a7f2a559a9048e19977efc70828e059f363f6e683592609562d3eaff3651d4', 'df4861d2295c7c890bcd51caea64f546692075c6c19e962cf2026c03df5b0c9a'),
        ('replace', 1027, 1028, 1027, 1028, 'b0896bf3c0751440d7d8c53791139b0a025a0aa971f4de2f5c5bb11edffd5ed5', 'df4861d2295c7c890bcd51caea64f546692075c6c19e962cf2026c03df5b0c9a'),
    ),
    'content/events_zh-CN/arc_midgame.json': (
        ('replace', 752, 753, 752, 753, '3df74ebc63ac9ab406308f8f540b40fd081956a9359409ad055efeb4dae8ec87', '3b576cac048d57249be5b1357f3640efeeacc4e9559cfbf84e444f53dedf3a93'),
        ('replace', 1027, 1028, 1027, 1028, 'd34b55c623b7a512c0276f5415dc025f0ed37a2437ab8b5dafd669dff48fe99d', '3b576cac048d57249be5b1357f3640efeeacc4e9559cfbf84e444f53dedf3a93'),
    ),
    'content/events_zh-TW/arc_midgame.json': (
        ('replace', 752, 753, 752, 753, '1b36f2009896f5bb346f0cf2478c17a7a62da64633be332053a80a5cd436b0a0', '3c812f5a4b306e982ba0fe32f1a2e317b01976348752b1adf43751e0b814abad'),
        ('replace', 1027, 1028, 1027, 1028, '86e98f92ff875bfe0d9a2f6b06a0af5b16981ac645739ad8ac8117e449531e56', '3c812f5a4b306e982ba0fe32f1a2e317b01976348752b1adf43751e0b814abad'),
    ),
}
FIRST_WIN_REPAIR_PARENT = '1bf0585f8010a1af4e69bbe4355826c15527896f'
FIRST_WIN_REPAIR_COMMIT = 'efacadafb59bb80c8fce10cb9d5937509ce22b1f'
FIRST_WIN_REPAIR_PATHS = (FIRST_WIN_KO_PATH,)
FIRST_WIN_REPAIR_RAW_SHA256 = {'content/events/arc_midgame.json': ('4edc95d3001a7e6df8b73c946f53855510305a9a464dbc1b75c5d26d4b309262',
                                     '58fd1fdff64a2adad1fbc28b770c4a35d78dfcb1f4ad02ddc303b52d535d3f89')}
FIRST_WIN_REPAIR_RAW_PATCHES = {'content/events/arc_midgame.json': (('replace',
                                      344,
                                      345,
                                      344,
                                      345,
                                      'f4c413096072d5af8587c658fc869d4db097da0514f718eaa3e74b55fcd76c75',
                                      '7d0f83dbbd1e2006a178762ea9037daa6f0b50d5341dc0bdd4009182616cdd68'),
                                     ('replace',
                                      4290,
                                      4291,
                                      4290,
                                      4291,
                                      'f4c413096072d5af8587c658fc869d4db097da0514f718eaa3e74b55fcd76c75',
                                      '7d0f83dbbd1e2006a178762ea9037daa6f0b50d5341dc0bdd4009182616cdd68'))}
FIRST_WIN_RECEIPT_PARENT = "037a858c4e70d7fa37d2950f22296b1669446308"
FIRST_WIN_RECEIPT_COMMIT = "bae21b2f297d4eb8f285448a23b5c391370782e4"
FIRST_WIN_RECEIPT_PATHS = (LEDGER_PATH,)
FIRST_WIN_RECEIPT_RAW_SHA256 = {
    LEDGER_PATH: ("9c540d3b5b4dc1ac5d3f28cbe96e6467bb9e6074266e7c01931e23b8fe49d191",
                  "3b0581aca338cd897aa162458cac86b59864d126344091dccdf4c9dc904ac9f9"),
}
FIRST_WIN_RECEIPT_BATCH_SHA256 = {
    "ja": "6ba6caa0f48a2b26bc89e92c906bcc6a745a336a156ce94c1602789a928af146",
    "zh-CN": "766f87e1c19dc7bed243a7fd6b52fd715aebff56e92dd8cfb99c58aa3db2a7f7",
    "zh-TW": "6db409be670659ff4706654a9dafab30d4b8fe172bdf729f84b7e65723843101",
}
FIRST_WIN_RECEIPT_SOURCE_MANIFEST_SHA256 = "673384fc1590f904c3f23e7e4688ca87a95eb60a71ce7f7f6dd564611f667a2c"
# A separate475 source/receipt edge; the five shared files do not merge its
# two night-routine literals with474's already accepted first-win results.
NIGHT_PATHS = FIRST_WIN_PATHS
NIGHT_KO_PATH = NIGHT_PATHS[0]
NIGHT_EVENT_ID = "arc_night_routine"
NIGHT_TEXT_LEAVES = tuple((NIGHT_EVENT_ID, ("choices", 1, field))
                          for field in ("result_text", "bridge_summary"))
NIGHT_PRODUCT_PARENT = 'd58583aaf7bb9dc53c249f7ad28def492e51e6aa'
NIGHT_PRODUCT_COMMIT = 'abd8eb37ebf1dd8cd7967365780e2cc8a5a0c4fd'
NIGHT_RAW_SHA256 = {'content/events/arc_midgame.json': ('58fd1fdff64a2adad1fbc28b770c4a35d78dfcb1f4ad02ddc303b52d535d3f89',
                                     '1cc0dcab4379e00253f76ed8686e5fa466081bac565cab8ba2df7df80277d952'),
 'content/events_en/arc_midgame.json': ('b7237dda9c0d87a6cf8f8845775916e0b4ee3cbceb2dd0da2e847513baaa21da',
                                        '5b2d2192d47cdb723cbd26a68bc9ef02bfb074d6134ed6e6f3b084243e2c81ed'),
 'content/events_ja/arc_midgame.json': ('63ebbdf7b91f4185789e06f66d84adec204c05118b99d0d0379e69dea85a20ad',
                                        '256b6d7686343685fae07f4ae78018f24cb79f694ed7ea306048c0146c92732d'),
 'content/events_zh-CN/arc_midgame.json': ('017d3161eb743cde8c660407b3684e1c1f0ee2e83b8d882f332c1e1c7a8a6514',
                                           'b45f0a4ac4da3bb98c291746c13ebc7caa90c138cdc2a90a381e754303619d2e'),
 'content/events_zh-TW/arc_midgame.json': ('dcc316943babc5293729c6bd07e20e25ca8e090975d4202a506b33d06e48a114',
                                           'a5acbfaa01570a6f64855b86104d84a78db1e1220e4ec2233eab2ec417f47f00')}
NIGHT_RAW_PATCHES = {'content/events/arc_midgame.json': (('replace',
                                      2150,
                                      2152,
                                      2150,
                                      2152,
                                      '239bbb8cc025ec07048553b219e95f5c6780c743cbd079e6b8f8de79ef5a8696',
                                      '615d2b7276991725393d00ce29043dd6c70300956a4710d7217e08b1db5c4c5b'),),
 'content/events_en/arc_midgame.json': (('replace',
                                         685,
                                         687,
                                         685,
                                         687,
                                         '678c3d733e4cecb1ed8a67eaa690fb45fc2a946e5400ed5f7dab6f0ff032d03a',
                                         '6149fe84838f433a0bb1ca18640ccc4324c9315355a5efbea39a32257e1c76cc'),),
 'content/events_ja/arc_midgame.json': (('replace',
                                         890,
                                         892,
                                         890,
                                         892,
                                         'ed8d0351a5ece3b9b1c0cf1da889a652a7857db9b8e10bc55dbe9fe969cd4b2e',
                                         '7766496fc78ecdff30b32837e63dc22e077e79aa87d42df4a28296cf3bb31a30'),),
 'content/events_zh-CN/arc_midgame.json': (('replace',
                                            890,
                                            892,
                                            890,
                                            892,
                                            '28b2d3e441a885a6a2e8fb219c6a89528ebad4d7da408820c08be0b574bedf29',
                                            '4212d77e92f6f94eb9aee2ac9c669c40ee05661bbd2bef8e482038044902cb8d'),),
 'content/events_zh-TW/arc_midgame.json': (('replace',
                                            890,
                                            892,
                                            890,
                                            892,
                                            'd1e90e11c332b03158cb69176c7e35bc14a03dab4b2eadfe33f92f6d107af699',
                                            '9fe3515b63db0a728a6c96d8e19e17f2da6efefe6f06aaeee49ca8e45e6815dc'),)}
NIGHT_RECEIPT_PARENT = "2b30fb563a120a1001f8beee8e02f1228b8f4e8f"
NIGHT_RECEIPT_COMMIT = "6f80f2d113b2b684909956dd9d701cc9b9832e38"
NIGHT_RECEIPT_PATHS = (LEDGER_PATH,)
NIGHT_RECEIPT_RAW_SHA256 = {
    LEDGER_PATH: ("3b0581aca338cd897aa162458cac86b59864d126344091dccdf4c9dc904ac9f9",
                  "2d609869aae88189f0c65dc0046f2585bc7b20e2df261115f4cb94f018f7a442"),
}
NIGHT_RECEIPT_BATCH_SHA256 = {
    "ja": "26062714f4daff16591073199399ce86cb40b314b6593426afdb68f2d55aa7d6",
    "zh-CN": "2bfba723394c5e86794231a7c0a95039f2f045b76089bfd579e4ea0e5a15f592",
    "zh-TW": "da80ac671e476f512a47791c1ee8896d13f85dd3da297c28c5371f1c454be850",
}
NIGHT_RECEIPT_SOURCE_MANIFEST_SHA256 = "90d88b6fe55939264625f49a36bfdc8ff7d10f93c7cd53b85a394f20f911cc05"
NIGHT_METADATA_PARENT = '170c5024b3e985980bc56f466537046cd6aa2c3c'
NIGHT_METADATA_COMMIT = 'aae4446cca8a48b55571e76ebcdd41fc0056de8b'
NIGHT_METADATA_PATHS = (INVENTORY_PATH, RATING_PATH)
NIGHT_METADATA_FINGERPRINTS = (
    ("sexuality", "c29603bb29735d6b371fa63cccd56c5106ee31312d8ab0bf3afa29145f3820ed",
     "d0dd2b37a6bab08ce17cebfe19ebacaf6170acccd56d4e0f110653704ade7a8f"),
    ("alcohol_tobacco_drugs", "7726b07a2373f4a97b43a077524e856702e68defa15c8c8492bb67b7c79a7fb6",
     "19836be587ee24a1561736047c5da80cd4f18262b175b1d66adde28aa6ebcda9"),
)
NIGHT_METADATA_RAW_SHA256 = {'content/meta/release_content_inventory.json': ('7ef8fbb45ba48afbd6509deaf3419d0cc6857e7abf046081724580a4234d0359',
                                                 '12a855c9d8770cc900e0d4aee042b691664a1ae43f51ac76693b89d51b89444c'),
 'docs/CONTENT_RATING_INVENTORY.md': ('912d38b3b002292e9eed9d7164b4bdbc1feb0393186d015a02ff20b8ca020187',
                                      '068bd504c03f7476126104d05ab0864e1721e1ca9839a1e2794e62dc1e283e40')}
NIGHT_METADATA_RAW_PATCHES = {'content/meta/release_content_inventory.json': (('replace',
                                                  532,
                                                  533,
                                                  532,
                                                  533,
                                                  '7ec89abb5f3ec7e0499b808a7b4ff4d77baa1ff40579482959c33dd9b5c6f928',
                                                  '565d8f79e508da0c0faf25b20196f3f894f6fd221f9aeb12b33f274706d8f16a'),
                                                 ('replace',
                                                  746,
                                                  747,
                                                  746,
                                                  747,
                                                  '2e3fde49be7078025c175810bc5ea0bd491973a8d9041dc2ee605d07c915e51c',
                                                  'e118c1d9796634b20af374518d03a2a473099fab1bc06d7ecc1760a06daa273b')),
 'docs/CONTENT_RATING_INVENTORY.md': (('replace',
                                       134,
                                       135,
                                       134,
                                       135,
                                       '18410c7181b2321b4dc7b47bae68888556d50914f95b568c7eca07884125d959',
                                       '598fe02930f2ed3d9064ec5202b8fae4c6d48b8272a66f72fa466f023b114d9d'),
                                      ('replace',
                                       139,
                                       140,
                                       139,
                                       140,
                                       'addac52662d75a849958f3e5e169fc14b96d5686c2a03046b8c55a9b229c0847',
                                       '02ed30844d82ac1c8b80bcbd88baf930b8901b0e0f1adf2bbe1ea2bf210bc9b8'))}
LOSS_HOLD_PATHS = NIGHT_PATHS
LOSS_HOLD_KO_PATH = LOSS_HOLD_PATHS[0]
LOSS_HOLD_TEXT_LEAVES = (("arc_invest_first_loss", ("choices", 1, "result_text")),)
LOSS_HOLD_PRODUCT_PARENT = "70ceeebdb67c4e3ab66dc2bd08cb21cf2598a343"
LOSS_HOLD_PRODUCT_COMMIT = "04ed119c6f0e31306ed89d62f2951ef6cc5490e5"
LOSS_HOLD_RAW_SHA256 = dict(zip(LOSS_HOLD_PATHS, (
    ("1cc0dcab4379e00253f76ed8686e5fa466081bac565cab8ba2df7df80277d952", "90be9165de0a4b6469f88d112745d8fe2292ba6aed889e36d3e01fcb55ab9440"),
    ("5b2d2192d47cdb723cbd26a68bc9ef02bfb074d6134ed6e6f3b084243e2c81ed", "051e0f44784ca5a39deac5aff1a50c1d14abd659abcc59893121b375b755a6d5"),
    ("256b6d7686343685fae07f4ae78018f24cb79f694ed7ea306048c0146c92732d", "d103e03acc26cb4fbf3ed6bff62862eda76266ca102e935d764870acb879e41e"),
    ("b45f0a4ac4da3bb98c291746c13ebc7caa90c138cdc2a90a381e754303619d2e", "44e6d7ed512ab400ae5ee2ec43e5c3c2619a9ccc214bdac476183d170fb9a613"),
    ("a5acbfaa01570a6f64855b86104d84a78db1e1220e4ec2233eab2ec417f47f00", "eef6145e91e24a35901515f328829413b26e4c5dc7ddab0926984aaaa29706bb"),
)))
LOSS_HOLD_RAW_PATCHES = dict(zip(LOSS_HOLD_PATHS, (
    (("replace", 2431, 2432, 2431, 2432, "482e58db0953b5d598b194e5fa9ae0c04c7e0f1639637d3155f222741aab17ab", "2467f62ed2db39c5f973b9bc5462d9e430a11ebc6fa0de98af0aa738c8c52fa6"),),
    (("replace", 788, 789, 788, 789, "e995a40e03cb8de27a75e23d7f6d4b1ec94bead1a826c52a9a8a3cf86b498c87", "fd4a17aefca69336bd73aee95b7087a8b581d9dff8a14df645a6f2a2b6906c3f"),),
    (("replace", 993, 994, 993, 994, "a5dfdb4dc594c5862dd0e6262a4ef2d0c28525138406e5c9c294b2c44b548fe0", "6f57c47caf92fbcf813218fac5d7160a99afa4840562144bede227a03cb3635c"),),
    (("replace", 993, 994, 993, 994, "97a36b2ff879dbbabc01c00746192a57220f7b740401aa15d0b403d66a5b3631", "596712842214ad73a07189c7ee68243be18d7edb65fe54e63f4eef688ce070f2"),),
    (("replace", 993, 994, 993, 994, "60e25368eba524b60e82731b6127c1f3a9e1ee1c900ecb60225e984c2aee53e9", "817feedfb1add6acfa1d8b0b5e1dfe8df17d4ffe19a0cfa22e4adc2f304d7a21"),),
)))
LOSS_HOLD_RECEIPT_PARENT = "fb9952cd1c5fbd8d128d487d20902ca10429a42d"
LOSS_HOLD_RECEIPT_COMMIT = "fb766fd7fc17a574bc00ffcbcd278fb03b797cee"
LOSS_HOLD_RECEIPT_PATHS = (LEDGER_PATH,)
LOSS_HOLD_RECEIPT_RAW_SHA256 = {
    LEDGER_PATH: ("2d609869aae88189f0c65dc0046f2585bc7b20e2df261115f4cb94f018f7a442",
                  "3902a0003fc48ca635510061d07fe6a1354bde5a46257c52de12164829b8f9cc"),
}
LOSS_HOLD_RECEIPT_BATCH_SHA256 = {
    "ja": "49aaa63b75353a45427a533609bee8cb6fd591b527990bee2a83067c481c3058",
    "zh-CN": "7a20edc740d59bb8fbf8bf6bdd4808fa5f4bc6f29216fa9e2a0ff2053c6990c9",
    "zh-TW": "4a3bd9d7fe6a21dc11f9467c90b20c958470dfe6b7f76b00add5fe56e09f93e4",
}
LOSS_HOLD_RECEIPT_SOURCE_MANIFEST_SHA256 = "cd3a8af9a4f972f4fea87ea1630b6d31013418d35e0b4b29f01c0a7cc67a314b"
LOSS_HOLD_METADATA_PARENT = "fb766fd7fc17a574bc00ffcbcd278fb03b797cee"
LOSS_HOLD_METADATA_COMMIT = "d1ef3d225b2364f90163cb7bb734ea03655ae45c"
LOSS_HOLD_METADATA_PATHS = (INVENTORY_PATH, RATING_PATH)
LOSS_HOLD_METADATA_FINGERPRINTS = (("fear", "0ce0b943d537d2b1162ebb6e2fce63be66002c713fd9a3eed691cc5ee7d826c9",
                                    "ee8f545970fb8a44eb26c298e1932284e16227e20c26dde245c6503e75594554"),)
LOSS_HOLD_METADATA_RAW_SHA256 = {
    INVENTORY_PATH: ("12a855c9d8770cc900e0d4aee042b691664a1ae43f51ac76693b89d51b89444c",
                     "9a7bb7be4aad760198f35b3461120b4d5cd41166f19b55081c27698efeffaeaa"),
    RATING_PATH: ("068bd504c03f7476126104d05ab0864e1721e1ca9839a1e2794e62dc1e283e40",
                  "d3387ea261a56189f120024eeec5390d1f46b5c3ed7ca2054e081ce52a78c942"),
}
LOSS_HOLD_METADATA_RAW_PATCHES = {
    INVENTORY_PATH: (("replace", 618, 619, 618, 619,
                      "e45ad99805a0f83c4b58b4fb33312a9cf052c784f4138e3ce8c5f207f307979d",
                      "3faa45b3688948b5e4d75672a9e4f86b41fb68779ff7176be8df9c540162434b"),),
    RATING_PATH: (("replace", 136, 137, 136, 137,
                   "ab1b3ab5e93e7b3e4b7ca572288c07338b362b41314ea3b33d70e0958e2d8a69",
                   "45cd084233cc509b0048e60b9acf1509416b34a272298262c088d8b1d93420c1"),),
}
_ACTIVE = contextvars.ContextVar("order470_source_proof", default=None)
_SEMANTIC_MEMO = contextvars.ContextVar("order470_semantic_memo", default=None)


def _require(ok, detail):
    if not ok:
        raise ValueError("ORDER-470: " + detail)


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _digest(value):
    return _sha(json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode())


def _git(root, *args, input=None):
    result = subprocess.run(("git", "--no-replace-objects", *args), cwd=root,
                            input=input, capture_output=True, timeout=30)
    _require(result.returncode == 0, "Git proof unavailable: " + " ".join(args))
    return result.stdout


def _objects(root, requests):
    output = _git(root, "cat-file", "--batch", input="".join(r[0] + "\n" for r in requests).encode())
    cursor, result = 0, []
    for expression, oid, kind in requests:
        end = output.find(b"\n", cursor)
        header = output[cursor:end].split() if end >= cursor else []
        _require(len(header) == 3 and header[:2] == [oid.encode(), kind.encode()]
                 and header[2].isdigit(), "object identity/type: " + expression)
        size = int(header[2])
        raw = output[end + 1:end + 1 + size]
        cursor = end + 1 + size
        _require(len(raw) == size and output[cursor:cursor + 1] == b"\n"
                 and hashlib.sha1(kind.encode() + b" " + str(size).encode() + b"\0" + raw).hexdigest() == oid,
                 "object bytes: " + expression)
        cursor += 1
        result.append(raw)
    _require(cursor == len(output), "trailing object proof")
    return result


def _snapshot(root, revision, paths):
    _require(isinstance(revision, str) and re.fullmatch(r"[0-9a-f]{40}", revision) is not None,
             "unbound product revision")
    commit = _objects(root, [(revision, revision, "commit")])[0]
    headers = commit.split(b"\n\n", 1)[0].splitlines()
    trees = [row[5:].decode() for row in headers if row.startswith(b"tree ")]
    _require(len(trees) == 1, "exact commit tree")
    _objects(root, [(trees[0], trees[0], "tree")])
    entries = {}
    for record in _git(root, "ls-tree", "-r", "-z", trees[0], "--", *paths).split(b"\0"):
        if record:
            meta, path = record.split(b"\t", 1)
            mode, kind, oid = meta.decode().split()
            _require(mode == "100644" and kind == "blob", "source mode/type " + path.decode())
            entries[path.decode()] = oid
    _require(set(entries) == set(paths), "exact snapshot path population")
    raw = _objects(root, [(revision + ":" + p, entries[p], "blob") for p in paths])
    return dict(zip(paths, raw)), headers


def _loads(raw):
    def pairs(rows):
        value = {}
        for key, child in rows:
            _require(key not in value, "duplicate JSON key")
            value[key] = child
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def _ordered(value):
    return json.dumps(value, ensure_ascii=False, allow_nan=False, separators=(",", ":"))


def _disk_bytes(path):
    # Historical UI collectors deliberately project Path.read_bytes/read_text.
    # Current admission must still observe physical disk, never that old view.
    with open(path, "rb") as stream:
        return stream.read()


def changed_text_selectors(before, after):
    """Derive exact text-only selectors, including the two neutral additions."""
    old, new = ({r["id"]: r for r in _loads(raw)} for raw in (before, after))
    result = []
    def visit(a, b, keys):
        if type(b) is dict:
            for key, value in b.items():
                visit(a.get(key) if type(a) is dict else None, value, (*keys, key))
        elif type(b) is list:
            for index, value in enumerate(b):
                visit(a[index] if type(a) is list and index < len(a) else None, value, (*keys, index))
        elif type(b) is str and keys[-1] in {"description", "text", "result_text"} and a != b:
            result.append((eid, keys))
    for eid in EVENT_IDS:
        visit(old[eid], new[eid], ())
    return tuple(result)


def _arc_inverse(before, after, path):
    old, new = _loads(before), _loads(after)
    _require(isinstance(old, list) and isinstance(new, list)
             and [r["id"] for r in old] == [r["id"] for r in new]
             and len({r["id"] for r in old}) == len(old), "exact event population/order")
    expected = copy.deepcopy(old)
    translated = path not in ARC_PATHS[:2]
    for a, b in zip(expected, new):
        eid = a["id"]
        if eid not in EVENT_IDS:
            continue
        # No whole-event replacement: untouched cast, effects, scheduling,
        # labels on counter, and every neighboring field stay byte-independent.
        if not translated:
            allowed = {("description",)}
            if eid == "arc_jaehyuk_04b_counter":
                allowed |= {("choices", i, "result_text") for i in (0, 2)}
            elif eid == "arc_jaehyuk_aftermath":
                allowed |= {("choices", i, k) for i, k in
                            ((0, "text"), (0, "result_text"), (1, "text"),
                             (1, "result_text"), (2, "text"))}
            else:
                allowed |= {("choices", i, k) for i in (0, 1) for k in ("text", "result_text")}
            for keys in allowed:
                left, right = a, b
                for key in keys[:-1]:
                    left, right = left[key], right[key]
                _require(isinstance(right[keys[-1]], str) and right[keys[-1]].strip(), "nonempty owned prose")
                left[keys[-1]] = right[keys[-1]]
        if eid == "arc_jaehyuk_aftermath":
            _require(len(a["choices"]) == 3 and len(b["choices"]) == 4, "sole neutral choice append")
            neutral = b["choices"][3]
            _require(set(neutral) == ({"text", "result_text", "requires_story_fact", "flags",
                                     "deferred_follow_up", "deferred_delay"} if path == KO_PATH
                                    else {"text", "result_text"}), "neutral exact field population")
            _require(all(isinstance(neutral[k], str) and neutral[k].strip() for k in ("text", "result_text")),
                     "neutral nonempty authored text")
            if path == KO_PATH:
                _require(neutral["requires_story_fact"] == "jaehyuk_unknown"
                         and neutral["flags"] == ["arc_jaehyuk_aftermath_seen"]
                         and neutral["deferred_follow_up"] == "arc_jaehyuk_mirror"
                         and type(neutral["deferred_delay"]) is int and neutral["deferred_delay"] == 1,
                         "neutral no reward/history invention and exact followup")
                for i, marker in enumerate(("jaehyuk_reported", "jaehyuk_used", "jaehyuk_victim")):
                    _require(isinstance(a["choices"][i].pop("conditions_note"), str), "old route note")
                    a["choices"][i]["requires_story_fact"] = marker
            a["choices"].append(copy.deepcopy(neutral))
        elif eid == "arc_daeun_later_echo" and path == KO_PATH:
            a["choices"][0]["requires_story_fact"] = "daeun_together"
    _require(expected == new, "arc successor exceeds three exact scenes/text/fact slots: " + path)
    # Structural equality alone never admits a reformatted neighbor. Both full
    # immutable raw pins above are required even when a caller asks for a view.
    return before


def _raw_inverse(before, after, path, pins, hunks):
    _require(path in pins and type(before) is bytes and type(after) is bytes
             and (_sha(before), _sha(after)) == pins.get(path), "unapproved raw pair: " + path)
    from difflib import SequenceMatcher
    old_lines, new_lines = before.splitlines(True), after.splitlines(True)
    patches = []
    restored = list(new_lines)
    opcodes = SequenceMatcher(None, old_lines, new_lines, autojunk=False).get_opcodes()
    for tag, a, z, b, end in opcodes:
        if tag != "equal":
            patches.append((tag, a, z, b, end, _sha(b"".join(old_lines[a:z])),
                            _sha(b"".join(new_lines[b:end]))))
    _require(tuple(patches) == hunks.get(path), "exact raw hunk coordinates/bytes: " + path)
    for tag, a, z, b, end in reversed(opcodes):
        if tag != "equal":
            restored[b:end] = old_lines[a:z]
    _require(b"".join(restored) == before, "whole raw inverse: " + path)
    return before


def product_inverse(before, after, path):
    _require(path in PRODUCT_PATHS, "unowned product path: " + path)
    _raw_inverse(before, after, path, RAW_SHA256, RAW_PATCHES)
    if path in ARC_PATHS:
        return _arc_inverse(before, after, path)
    if path == INVENTORY_PATH:
        old, new = _loads(before), _loads(after)
        changed = []
        def compare(a, b, keys=()):
            if type(a) is dict and type(b) is dict:
                _require(list(a) == list(b), "inventory key order/population")
                for key in a:
                    compare(a[key], b[key], (*keys, key))
            elif type(a) is list and type(b) is list:
                _require(len(a) == len(b), "inventory list population")
                for i, (x, y) in enumerate(zip(a, b)):
                    compare(x, y, (*keys, i))
            elif a != b:
                _require(keys[-1] == "expected_content_sha256" and isinstance(b, str)
                         and re.fullmatch(r"[0-9a-f]{64}", b) is not None,
                         "inventory outside existing content fingerprints")
                changed.append(keys)
        compare(old, new)
        _require(len(changed) == 3, "three existing inventory fingerprints only")
    return before


def _person_arc_inverse(before, after, path):
    _require(path in PERSON_PATHS, "unowned person-deal path")
    old, new = _loads(before), _loads(after)
    _require(type(old) is list and type(new) is list
             and [row["id"] for row in old] == [row["id"] for row in new]
             and len({row["id"] for row in old}) == len(old), "person-deal event order/population")
    expected = copy.deepcopy(old)
    index = next((i for i, row in enumerate(old) if row["id"] == PERSON_EVENT_ID), None)
    _require(index is not None, "person-deal owner missing")
    a, b = expected[index], new[index]
    _require("description_if_known" not in a and type(b.get("description_if_known")) is dict
             and tuple(b["description_if_known"]) == PERSON_DIK_KEYS,
             "person-deal exact divorced-first two-key addition")
    _require(all(type(value) is str and value.strip() for value in b["description_if_known"].values()),
             "person-deal nonempty conditional prose")
    a["description_if_known"] = copy.deepcopy(b["description_if_known"])
    if path in PERSON_PATHS[:2]:
        for _eid, keys in PERSON_EDITED_TEXT_LEAVES:
            left, right = a, b
            for key in keys[:-1]:
                left, right = left[key], right[key]
            _require(type(right[keys[-1]]) is str and right[keys[-1]].strip()
                     and left[keys[-1]] != right[keys[-1]], "person-deal exact four authored edits")
            left[keys[-1]] = right[keys[-1]]
        _require(b["description"] == b["description_if_known"][PERSON_DIK_KEYS[0]],
                 "person-deal divorced prose must equal the neutral default")
    # Placement of the new member is covered by exact raw hunks; all old key
    # orders, gameplay, other labels and neighboring events stay unchanged.
    actual_without_dik = copy.deepcopy(new)
    expected_without_dik = copy.deepcopy(expected)
    for rows in (actual_without_dik, expected_without_dik):
        rows[index].pop("description_if_known")
    _require(_ordered(expected_without_dik) == _ordered(actual_without_dik),
             "person-deal source exceeds four text edits and exact DIK pair")
    return before


def person_product_inverse(before, after, path):
    _require(path in PERSON_PRODUCT_PATHS, "unowned person-deal product path")
    _raw_inverse(before, after, path, PERSON_RAW_SHA256, PERSON_RAW_PATCHES)
    return _person_arc_inverse(before, after, path)


def prose_selectors(path):
    _require(path in PROSE_PATHS, "unowned recall prose path")
    name = Path(path).stem
    return tuple((eid, keys) for owner, eid, paths in PROSE_SELECTORS if owner == name for keys in paths)


def prose_product_inverse(before, after, path):
    _require(path in PROSE_PRODUCT_PATHS, "unowned recall source path")
    _raw_inverse(before, after, path, PROSE_RAW_SHA256, PROSE_RAW_PATCHES)
    selected = prose_selectors(path)
    return _receipt_overlay_inverse(before, after, path, selected, PROSE_PRODUCT_PATHS,
                                    PROSE_RAW_SHA256, (), len(selected))


def _prose_metadata_semantics(before, after, path):
    _require(path in PROSE_METADATA_PATHS and type(before) is bytes and type(after) is bytes,
             "unowned recall metadata path/raw")
    old_hash, new_hash = PROSE_METADATA_FINGERPRINTS
    _require(before.count(old_hash.encode()) == after.count(new_hash.encode()) == 1
             and after.replace(new_hash.encode(), old_hash.encode()) == before,
             "recall metadata changes exactly one fingerprint literal and no neighboring bytes")
    if path == INVENTORY_PATH:
        old, new = _loads(before), _loads(after)
        indices = [i for i, row in enumerate(old["content_axes"]) if row["id"] == "sexuality"]
        _require(len(indices) == 1, "exact sexuality inventory owner")
        index = indices[0]
        expected = copy.deepcopy(old)
        scan = expected["content_axes"][index]["candidate_scan"]
        _require(scan["expected_content_sha256"] == old_hash
                 and new["content_axes"][index]["candidate_scan"]["expected_content_sha256"] == new_hash,
                 "recall fingerprint belongs to sexuality candidate content only")
        scan["expected_content_sha256"] = new_hash
        _require(_ordered(expected) == _ordered(new), "inventory population/classification/decision changed")
    return before


def prose_metadata_inverse(before, after, path):
    _require(path in PROSE_METADATA_PATHS, "unowned recall metadata inverse")
    _raw_inverse(before, after, path, PROSE_METADATA_RAW_SHA256, PROSE_METADATA_RAW_PATCHES)
    return _prose_metadata_semantics(before, after, path)


def ending_product_inverse(before, after, path, *, repair=False):
    """Comparison only: exact21 strings, or the separately pinned EN12 repair."""
    _require(type(repair) is bool, "ending source stage kind")
    paths = ENDING_REPAIR_PATHS if repair else ENDING_PATHS
    pins = ENDING_REPAIR_RAW_SHA256 if repair else ENDING_RAW_SHA256
    hunks = ENDING_REPAIR_RAW_PATCHES if repair else ENDING_RAW_PATCHES
    selectors = ENDING_REPAIR_LEAVES if repair else ENDING_TEXT_LEAVES
    _require(path in paths and len(selectors) == len(set(selectors)) == (12 if repair else 21),
             "ending exact path/selector population")
    _raw_inverse(before, after, path, pins, hunks)
    return _receipt_overlay_inverse(before, after, path, selectors, paths, pins, (), len(selectors))


def _ending_metadata_semantics(before, after, path):
    _require(path in ENDING_METADATA_PATHS and type(before) is bytes and type(after) is bytes
             and type(ENDING_METADATA_FINGERPRINTS) is tuple and len(ENDING_METADATA_FINGERPRINTS) == 2,
             "unbound ending metadata path/fingerprints")
    old_hash, new_hash = ENDING_METADATA_FINGERPRINTS
    _require(old_hash != new_hash and all(type(h) is str and re.fullmatch(r"[0-9a-f]{64}", h)
             for h in (old_hash, new_hash)) and before.count(old_hash.encode()) == 1
             and after.count(new_hash.encode()) == 1, "ending exact fingerprint literals")
    _require(after.replace(new_hash.encode(), old_hash.encode()) == before,
             "ending metadata neighboring bytes changed")
    if path == INVENTORY_PATH:
        expected, new = _loads(before), _loads(after)
        corpus = expected["corpus_contract"]
        _require(corpus["ending_content_sha256"] == old_hash
                 and new["corpus_contract"]["ending_content_sha256"] == new_hash,
                 "ending fingerprint belongs only to current KO/EN corpus content")
        corpus["ending_content_sha256"] = new_hash
        _require(_ordered(expected) == _ordered(new), "ending population/classification/decision changed")
    return before


def ending_metadata_inverse(before, after, path):
    _require(path in ENDING_METADATA_PATHS, "unowned ending metadata inverse")
    _raw_inverse(before, after, path, ENDING_METADATA_RAW_SHA256, ENDING_METADATA_RAW_PATCHES)
    return _ending_metadata_semantics(before, after, path)


def _first_win_repair_semantics(before, after, path):
    """Only the same two Korean price spellings change after the initial source."""
    _require(path == FIRST_WIN_KO_PATH and isinstance(before, bytes) and isinstance(after, bytes),
             "first-win repair is Korean raw bytes only")
    old, new = "1만5천원짜리".encode(), "15,000원짜리".encode()
    _require(before.count(old) == after.count(new) == 2 and new not in before and old not in after
             and before.replace(old, new) == after, "first-win repair exact two price spellings")
    return _receipt_overlay_inverse(before, after, path, FIRST_WIN_TEXT_LEAVES, FIRST_WIN_REPAIR_PATHS,
                                    {path: (_sha(before), _sha(after))}, (), 2)


def first_win_product_inverse(before, after, path, *, repair=False):
    """Comparison-only inverse of exactly the two existing result literals."""
    _require(type(repair) is bool and path in (FIRST_WIN_REPAIR_PATHS if repair else FIRST_WIN_PATHS)
             and len(FIRST_WIN_TEXT_LEAVES) == len(set(FIRST_WIN_TEXT_LEAVES)) == 2,
             "first-win exact source path/selector population")
    _raw_inverse(before, after, path, FIRST_WIN_REPAIR_RAW_SHA256 if repair else FIRST_WIN_RAW_SHA256,
                 FIRST_WIN_REPAIR_RAW_PATCHES if repair else FIRST_WIN_RAW_PATCHES)
    if repair:
        return _first_win_repair_semantics(before, after, path)
    return _receipt_overlay_inverse(before, after, path, FIRST_WIN_TEXT_LEAVES, FIRST_WIN_PATHS,
                                    FIRST_WIN_RAW_SHA256, (), 2)


def night_routine_product_inverse(before, after, path):
    """Comparison-only inverse of the result and bridge summary, not runtime."""
    _require(path in NIGHT_PATHS and len(NIGHT_TEXT_LEAVES) == len(set(NIGHT_TEXT_LEAVES)) == 2,
             "night-routine exact source path/selector population")
    _raw_inverse(before, after, path, NIGHT_RAW_SHA256, NIGHT_RAW_PATCHES)
    return _receipt_overlay_inverse(before, after, path, NIGHT_TEXT_LEAVES, NIGHT_PATHS,
                                    NIGHT_RAW_SHA256, (), 2)


def _night_metadata_semantics(before, after, path):
    """Only the two measured current candidate-content fingerprints may move."""
    _require(path in NIGHT_METADATA_PATHS and type(before) is bytes and type(after) is bytes
             and type(NIGHT_METADATA_FINGERPRINTS) is tuple
             and tuple(row[0] for row in NIGHT_METADATA_FINGERPRINTS) == ("sexuality", "alcohol_tobacco_drugs")
             and all(type(row) is tuple and len(row) == 3 for row in NIGHT_METADATA_FINGERPRINTS),
             "night metadata exact path/raw/two-axis population")
    restored = after
    for _axis, old, new in NIGHT_METADATA_FINGERPRINTS:
        _require(old != new and all(type(h) is str and re.fullmatch(r"[0-9a-f]{64}", h) for h in (old, new))
                 and before.count(old.encode()) == after.count(new.encode()) == 1
                 and new.encode() not in before and old.encode() not in after,
                 "night metadata exact fingerprint literals")
        restored = restored.replace(new.encode(), old.encode())
    _require(restored == before, "night metadata changes neighboring raw bytes")
    if path == INVENTORY_PATH:
        old, new = _Document(before), _Document(after)
        expected, replacements = copy.deepcopy(old.value), []
        for axis, old_hash, new_hash in NIGHT_METADATA_FINGERPRINTS:
            indices = [i for i, row in enumerate(old.value["content_axes"]) if row["id"] == axis]
            _require(len(indices) == 1, "night metadata exact candidate owner")
            index = indices[0]
            keys = ("content_axes", index, "candidate_scan", "expected_content_sha256")
            _require(_leaf(old.value, keys) == old_hash and _leaf(new.value, keys) == new_hash,
                     "night fingerprint belongs to current candidate content only")
            expected["content_axes"][index]["candidate_scan"]["expected_content_sha256"] = new_hash
            a, z = old.spans[keys]
            b, end = new.spans[keys]
            replacements.append((b, end, old.text[a:z]))
        _require(_ordered(expected) == _ordered(new.value), "night inventory census/classification/decision changed")
        restored = new.text
        for a, z, literal in sorted(replacements, reverse=True):
            restored = restored[:a] + literal + restored[z:]
        _require(restored.encode() == before, "night inventory literal-only inverse")
    return before


def loss_hold_product_inverse(before, after, path):
    """Only477's one result literal; this is never a runtime payload."""
    _require(path in LOSS_HOLD_PATHS and LOSS_HOLD_TEXT_LEAVES ==
             (("arc_invest_first_loss", ("choices", 1, "result_text")),), "loss-hold exact selector/path")
    _raw_inverse(before, after, path, LOSS_HOLD_RAW_SHA256, LOSS_HOLD_RAW_PATCHES)
    return _receipt_overlay_inverse(before, after, path, LOSS_HOLD_TEXT_LEAVES,
                                    LOSS_HOLD_PATHS, LOSS_HOLD_RAW_SHA256, (), 1)


def _loss_hold_metadata_semantics(before, after, path):
    _require(path in LOSS_HOLD_METADATA_PATHS and type(before) is bytes and type(after) is bytes
             and len(LOSS_HOLD_METADATA_FINGERPRINTS) == 1
             and LOSS_HOLD_METADATA_FINGERPRINTS[0][0] == "fear", "loss-hold metadata exact owner")
    _axis, old, new = LOSS_HOLD_METADATA_FINGERPRINTS[0]
    _require(old != new and all(type(h) is str and re.fullmatch(r"[0-9a-f]{64}", h) for h in (old, new))
             and before.count(old.encode()) == after.count(new.encode()) == 1
             and new.encode() not in before and old.encode() not in after
             and after.replace(new.encode(), old.encode()) == before, "loss-hold metadata literal-only change")
    if path == INVENTORY_PATH:
        prior, current = _Document(before), _Document(after)
        indices = [i for i, row in enumerate(prior.value["content_axes"]) if row["id"] == "fear"]
        _require(len(indices) == 1, "loss-hold metadata unique fear owner")
        index = indices[0]
        keys = ("content_axes", index, "candidate_scan", "expected_content_sha256")
        _require(_leaf(prior.value, keys) == old and _leaf(current.value, keys) == new,
                 "loss-hold fingerprint is candidate content only")
        expected = copy.deepcopy(prior.value)
        expected["content_axes"][index]["candidate_scan"]["expected_content_sha256"] = new
        _require(_ordered(expected) == _ordered(current.value), "loss-hold inventory population/classification changed")
        a, z = prior.spans[keys]
        b, end = current.spans[keys]
        _require((current.text[:b] + prior.text[a:z] + current.text[end:]).encode() == before,
                 "loss-hold metadata JSON span inverse")
    return before


def loss_hold_metadata_inverse(before, after, path):
    _raw_inverse(before, after, path, LOSS_HOLD_METADATA_RAW_SHA256, LOSS_HOLD_METADATA_RAW_PATCHES)
    return _loss_hold_metadata_semantics(before, after, path)


def night_metadata_inverse(before, after, path):
    _require(path in NIGHT_METADATA_PATHS, "unowned night metadata inverse")
    _raw_inverse(before, after, path, NIGHT_METADATA_RAW_SHA256, NIGHT_METADATA_RAW_PATCHES)
    return _night_metadata_semantics(before, after, path)


def _configuration():
    return (PRODUCT_PARENT, PRODUCT_COMMIT, PRODUCT_PATHS, SOURCE_PATHS,
            copy.deepcopy(RAW_SHA256), copy.deepcopy(RAW_PATCHES), RECEIPT_PARENT,
            RECEIPT_COMMIT, copy.deepcopy(RECEIPT_RAW_SHA256), copy.deepcopy(RECEIPT_BATCH_SHA256),
            RECEIPT_SOURCE_MANIFEST_SHA256, ARC_PATHS, KO_PATH, RUNTIME_PATHS, INVENTORY_PATH,
            RATING_PATH, LEDGER_PATH, EVENT_IDS, ADDED_TEXT_LEAVES, LOCALES, RECEIPT_PATHS,
            PREDECESSOR_SOURCE_MANIFEST_SHA256, ROOT, __file__,
            PERSON_EVENT_ID, PERSON_PATHS, PERSON_KO_PATH, PERSON_DIK_KEYS,
            PERSON_EDITED_TEXT_LEAVES, PERSON_ADDED_TEXT_LEAVES, PERSON_TEXT_LEAVES,
            PERSON_PRODUCT_PATHS, PERSON_PRODUCT_PARENT, PERSON_PRODUCT_COMMIT,
            copy.deepcopy(PERSON_RAW_SHA256), copy.deepcopy(PERSON_RAW_PATCHES),
            PERSON_RECEIPT_PATHS, PERSON_RECEIPT_PARENT, PERSON_RECEIPT_COMMIT,
            copy.deepcopy(PERSON_RECEIPT_RAW_SHA256), copy.deepcopy(PERSON_RECEIPT_BATCH_SHA256),
            PERSON_RECEIPT_SOURCE_MANIFEST_SHA256,
            PROSE_SELECTORS, PROSE_TEXT_LEAVES, PROSE_NAMES, PROSE_PATHS, PROSE_KO_PATHS,
            PROSE_PRODUCT_PATHS, PROSE_PRODUCT_PARENT, PROSE_PRODUCT_COMMIT,
            copy.deepcopy(PROSE_RAW_SHA256), copy.deepcopy(PROSE_RAW_PATCHES),
            PROSE_RECEIPT_PATHS, PROSE_RECEIPT_PARENT, PROSE_RECEIPT_COMMIT,
            copy.deepcopy(PROSE_RECEIPT_RAW_SHA256), copy.deepcopy(PROSE_RECEIPT_CHANGED_LEAVES),
            copy.deepcopy(PROSE_RECEIPT_BATCH_SHA256), PROSE_RECEIPT_SOURCE_MANIFEST_SHA256,
            PROSE_METADATA_PARENT, PROSE_METADATA_COMMIT, PROSE_METADATA_PATHS,
            PROSE_METADATA_FINGERPRINTS, copy.deepcopy(PROSE_METADATA_RAW_SHA256),
            copy.deepcopy(PROSE_METADATA_RAW_PATCHES),
            ENDING_PATHS, ENDING_KO_PATH, ENDING_SELECTORS, ENDING_TEXT_LEAVES,
            ENDING_PRODUCT_PARENT, ENDING_PRODUCT_COMMIT, copy.deepcopy(ENDING_RAW_SHA256),
            copy.deepcopy(ENDING_RAW_PATCHES), ENDING_REPAIR_PARENT, ENDING_REPAIR_COMMIT,
            ENDING_REPAIR_PATHS, ENDING_REPAIR_LEAVES, copy.deepcopy(ENDING_REPAIR_RAW_SHA256),
            copy.deepcopy(ENDING_REPAIR_RAW_PATCHES), ENDING_RECEIPT_PARENT, ENDING_RECEIPT_COMMIT,
            ENDING_RECEIPT_PATHS, copy.deepcopy(ENDING_RECEIPT_RAW_SHA256),
            copy.deepcopy(ENDING_RECEIPT_BATCH_SHA256), ENDING_RECEIPT_SOURCE_MANIFEST_SHA256,
            ENDING_METADATA_PARENT, ENDING_METADATA_COMMIT, ENDING_METADATA_PATHS,
            copy.deepcopy(ENDING_METADATA_FINGERPRINTS), copy.deepcopy(ENDING_METADATA_RAW_SHA256),
            copy.deepcopy(ENDING_METADATA_RAW_PATCHES), ending_product_inverse, ending_metadata_inverse,
            _ending_metadata_semantics,
            _ending_stages, _ending_snapshot, _ending_source_comparison, _ending_ledger_inverse,
            _ending_receipt_semantics, _ending_receipt_exports, _validate_ending_receipts,
            FIRST_WIN_PATHS, FIRST_WIN_KO_PATH, FIRST_WIN_EVENT_IDS, FIRST_WIN_TEXT_LEAVES,
            FIRST_WIN_PRODUCT_PARENT, FIRST_WIN_PRODUCT_COMMIT, copy.deepcopy(FIRST_WIN_RAW_SHA256),
            copy.deepcopy(FIRST_WIN_RAW_PATCHES), FIRST_WIN_REPAIR_PARENT, FIRST_WIN_REPAIR_COMMIT,
            FIRST_WIN_REPAIR_PATHS, copy.deepcopy(FIRST_WIN_REPAIR_RAW_SHA256),
            copy.deepcopy(FIRST_WIN_REPAIR_RAW_PATCHES), FIRST_WIN_RECEIPT_PARENT, FIRST_WIN_RECEIPT_COMMIT,
            FIRST_WIN_RECEIPT_PATHS, copy.deepcopy(FIRST_WIN_RECEIPT_RAW_SHA256),
            copy.deepcopy(FIRST_WIN_RECEIPT_BATCH_SHA256), FIRST_WIN_RECEIPT_SOURCE_MANIFEST_SHA256,
            first_win_product_inverse, _first_win_repair_semantics, _first_win_stages, _first_win_receipt_semantics,
            _first_win_receipt_exports, _validate_first_win_receipts, _first_win_source_comparison,
            NIGHT_PATHS, NIGHT_KO_PATH, NIGHT_EVENT_ID, NIGHT_TEXT_LEAVES,
            NIGHT_PRODUCT_PARENT, NIGHT_PRODUCT_COMMIT, copy.deepcopy(NIGHT_RAW_SHA256),
            copy.deepcopy(NIGHT_RAW_PATCHES), NIGHT_RECEIPT_PARENT, NIGHT_RECEIPT_COMMIT,
            NIGHT_RECEIPT_PATHS, copy.deepcopy(NIGHT_RECEIPT_RAW_SHA256),
            copy.deepcopy(NIGHT_RECEIPT_BATCH_SHA256), NIGHT_RECEIPT_SOURCE_MANIFEST_SHA256,
            night_routine_product_inverse, _night_stages, _night_receipt_semantics,
            _night_receipt_exports, _validate_night_receipts, _night_source_comparison,
            NIGHT_METADATA_PARENT, NIGHT_METADATA_COMMIT, NIGHT_METADATA_PATHS,
            NIGHT_METADATA_FINGERPRINTS, copy.deepcopy(NIGHT_METADATA_RAW_SHA256),
            copy.deepcopy(NIGHT_METADATA_RAW_PATCHES), _night_metadata_stage,
            _night_metadata_semantics, night_metadata_inverse,
            historical_first_win_comparison,
            LOSS_HOLD_PATHS, LOSS_HOLD_KO_PATH, LOSS_HOLD_TEXT_LEAVES,
            LOSS_HOLD_PRODUCT_PARENT, LOSS_HOLD_PRODUCT_COMMIT,
            copy.deepcopy(LOSS_HOLD_RAW_SHA256), copy.deepcopy(LOSS_HOLD_RAW_PATCHES),
            LOSS_HOLD_RECEIPT_PARENT, LOSS_HOLD_RECEIPT_COMMIT, LOSS_HOLD_RECEIPT_PATHS,
            copy.deepcopy(LOSS_HOLD_RECEIPT_RAW_SHA256), copy.deepcopy(LOSS_HOLD_RECEIPT_BATCH_SHA256),
            LOSS_HOLD_RECEIPT_SOURCE_MANIFEST_SHA256, LOSS_HOLD_METADATA_PARENT, LOSS_HOLD_METADATA_COMMIT,
            LOSS_HOLD_METADATA_PATHS, LOSS_HOLD_METADATA_FINGERPRINTS,
            copy.deepcopy(LOSS_HOLD_METADATA_RAW_SHA256), copy.deepcopy(LOSS_HOLD_METADATA_RAW_PATCHES),
            loss_hold_product_inverse, loss_hold_metadata_inverse, _loss_hold_metadata_semantics,
            _loss_hold_stages, _loss_hold_receipt_semantics, _loss_hold_receipt_exports,
            _validate_loss_hold_receipts, _loss_hold_source_comparison, historical_loss_hold_comparison,
            _correction_ledger_inverse,
            _git, _objects, _snapshot, _disk_bytes, product_inverse, _arc_inverse, _raw_inverse,
            _validate_receipts, _receipt_semantics, _receipt_exports, receipt_overlay_inverse,
            _receipt_overlay_inverse, _event_receipt_semantics, person_product_inverse,
            _person_arc_inverse, person_receipt_overlay_inverse, _person_receipt_semantics,
            _person_receipt_exports, _validate_person_receipts, _person_stages,
            _person_source_comparison,
            prose_selectors, prose_product_inverse, prose_receipt_overlay_inverse,
            _prose_receipt_semantics, _prose_receipt_exports, _validate_prose_receipts,
            _prose_stages, _prose_source_comparison,
            _prose_metadata_stage, prose_metadata_inverse, _prose_metadata_semantics,
            changed_text_selectors, _Document, _Document.walk, _Document.ws,
            _loads, _ordered, _leaf, _sha, _digest, _require, _read_proof, _read_proof_current,
            _memoized_semantics, _semantic_binding, _configuration,
            hashlib.sha256, hashlib.sha1, json.loads, json.dumps, copy.deepcopy)


def _semantic_binding(root):
    root = Path(root).resolve()
    module = Path(__file__).resolve()
    _require(module == root / "tools/order470_source_compat.py", "proof module/root identity changed")
    return root, _configuration(), _disk_bytes(module)


def _memoized_semantics(label, inputs, calculate):
    """Cache successful pure calculations only; no Git/disk admission is cached."""
    memo = _SEMANTIC_MEMO.get()
    if memo is None:
        return calculate()
    key = (label, inputs)  # Exact immutable raw bytes, not a digest-only claim.
    if key not in memo[1]:
        result = calculate()
        _require(type(result) is bytes or (type(result) is tuple
                 and all(type(value) is str for value in result)), "mutable semantic result")
        memo[1][key] = result
    return memo[1][key]


class _Document:
    """Strict JSON literal spans; target inverse must preserve every other byte."""
    def __init__(self, raw):
        self.value, self.text, self.spans = _loads(raw), raw.decode("utf-8"), {}
        end = self.walk(0, ())
        _require(not self.text[end:].strip(), "trailing JSON bytes")

    def ws(self, index):
        if type(self) is _Document:
            text = self.text
            if type(text) is str and type(index) is int:
                length = len(text)
                if 0 <= index <= length:
                    if index == length or not text[index].isspace():
                        return index
                    next_index = index + 1
                    if next_index == length or not text[next_index].isspace():
                        return next_index
                    return re.compile(r"\s*").match(text, index).end()
        while index < len(self.text) and self.text[index].isspace():
            index += 1
        return index

    def walk(self, index, keys):
        start = index = self.ws(index)
        char = self.text[index]
        if char == "{":
            index = self.ws(index + 1)
            while self.text[index] != "}":
                key, index = json.JSONDecoder().raw_decode(self.text, index)
                index = self.ws(index)
                _require(self.text[index] == ":", "missing JSON colon")
                index = self.ws(self.walk(index + 1, (*keys, key)))
                if self.text[index] != ",":
                    break
                index = self.ws(index + 1)
            index += 1
        elif char == "[":
            index, ordinal = self.ws(index + 1), 0
            while self.text[index] != "]":
                index = self.ws(self.walk(index, (*keys, ordinal)))
                ordinal += 1
                if self.text[index] != ",":
                    break
                index = self.ws(index + 1)
            index += 1
        else:
            _, index = json.JSONDecoder().raw_decode(self.text, index)
        self.spans[keys] = (start, index)
        return index


def _leaf(row, keys):
    for key in keys:
        row = row[key]
    return row


def receipt_overlay_inverse(before, after, path, selectors):
    return _receipt_overlay_inverse(before, after, path, selectors, ARC_PATHS[2:],
                                    RECEIPT_RAW_SHA256, ADDED_TEXT_LEAVES, 12)


def person_receipt_overlay_inverse(before, after, path):
    # Japanese retains the two source-stage DIK drafts; the Chinese official
    # responses also correct their quantity wording. All six remain owned
    # receipt selectors, but the exact changed-string populations are 4/6/6.
    unchanged = PERSON_ADDED_TEXT_LEAVES if path == PERSON_PATHS[2] else ()
    count = 4 if path == PERSON_PATHS[2] else 6
    return _receipt_overlay_inverse(before, after, path, PERSON_TEXT_LEAVES, PERSON_PATHS[2:],
                                    PERSON_RECEIPT_RAW_SHA256, unchanged, count)


def prose_receipt_overlay_inverse(before, after, path):
    _require(path in PROSE_PATHS[10:], "unowned recall receipt target")
    selected = PROSE_RECEIPT_CHANGED_LEAVES.get(path, ())
    _require(selected and len(selected) == len(set(selected)) and set(selected) <= set(prose_selectors(path)),
             "recall receipt exact changed-string selectors")
    return _receipt_overlay_inverse(before, after, path, selected, PROSE_PATHS[10:],
                                    PROSE_RECEIPT_RAW_SHA256, (), len(selected))


def _receipt_overlay_inverse(before, after, path, selectors, paths, pins, additions, count):
    _require(path in paths and (_sha(before), _sha(after)) == pins.get(path),
             "target receipt raw pair")
    old, new = _Document(before), _Document(after)
    _require([r["id"] for r in old.value] == [r["id"] for r in new.value], "target event order/population")
    indices = {r["id"]: i for i, r in enumerate(old.value)}
    _require(len(indices) == len(old.value), "target duplicate event")
    expected, replacements = copy.deepcopy(old.value), []
    selected = set(selectors) - set(additions)
    _require(len(selected) == count, "exact existing target correction population")
    for eid, keys in selected:
        i = indices[eid]
        before_text, after_text = _leaf(old.value[i], keys), _leaf(new.value[i], keys)
        _require(type(before_text) is str and type(after_text) is str and before_text != after_text,
                 "existing target correction must change only an owned string")
        node = expected[i]
        for key in keys[:-1]:
            node = node[key]
        node[keys[-1]] = after_text
        a, z = old.spans[(i, *keys)]
        b, end = new.spans[(i, *keys)]
        replacements.append((b, end, old.text[a:z]))
    _require(_ordered(expected) == _ordered(new.value), "unowned target data changed")
    restored = new.text
    for a, z, old_text in sorted(replacements, reverse=True):
        restored = restored[:a] + old_text + restored[z:]
    _require(restored.encode("utf-8") == before, "target raw changed outside exact owned JSON strings")
    return before


def _receipt_semantics(before, after, source_before):
    selectors = changed_text_selectors(source_before[KO_PATH], before[KO_PATH])
    _require(len(selectors) == 14 and set(ADDED_TEXT_LEAVES) <= set(selectors), "exact14 receipt selectors")
    return _event_receipt_semantics(before, after, selectors, person=False)


def _person_receipt_semantics(before, after):
    for path in PERSON_PATHS:
        row = next(row for row in _loads(after[path]) if row["id"] == PERSON_EVENT_ID)
        _require(tuple(row.get("description_if_known", {})) == PERSON_DIK_KEYS
                 and row["description"] == row["description_if_known"][PERSON_DIK_KEYS[0]],
                 "accepted person-deal default/divorced text and key order")
    return _event_receipt_semantics(before, after, PERSON_TEXT_LEAVES, person=True)


def _prose_receipt_semantics(before, after):
    _require(len(PROSE_TEXT_LEAVES) == len(set(PROSE_TEXT_LEAVES)) == 40
             and set(PROSE_RECEIPT_CHANGED_LEAVES) == set(PROSE_PATHS[10:]),
             "recall exact40 receipt selectors and fifteen target paths")
    return _event_receipt_semantics(before, after, PROSE_TEXT_LEAVES, person=False, prose=True)


def _event_receipt_semantics(before, after, selectors, *, person, prose=False, ending=False, first_win=False, night=False, loss_hold=False):
    # Only these six named transitions use the shared official-header grammar.
    # Their path, count, source census, raw and batch pins remain independent.
    _require(all(type(flag) is bool for flag in (person, prose, ending, first_win, night, loss_hold))
             and sum((person, prose, ending, first_win, night, loss_hold)) <= 1
             and set(before) == set(after), "receipt stage/snapshot shape")
    paths = PERSON_PATHS if person else ARC_PATHS
    ko_path = paths[0]
    receipt_paths = PERSON_RECEIPT_PATHS if person else RECEIPT_PATHS
    pins = PERSON_RECEIPT_RAW_SHA256 if person else RECEIPT_RAW_SHA256
    batches = PERSON_RECEIPT_BATCH_SHA256 if person else RECEIPT_BATCH_SHA256
    source_manifest = PERSON_RECEIPT_SOURCE_MANIFEST_SHA256 if person else RECEIPT_SOURCE_MANIFEST_SHA256
    added = PERSON_ADDED_TEXT_LEAVES if person else ADDED_TEXT_LEAVES
    count, order = (6, "ORDER-471") if person else (14, "ORDER-470")
    if prose:
        paths, ko_path, added, count, order = PROSE_PATHS, None, (), 40, "ORDER-472"
        receipt_paths, pins = PROSE_RECEIPT_PATHS, PROSE_RECEIPT_RAW_SHA256
        batches, source_manifest = PROSE_RECEIPT_BATCH_SHA256, PROSE_RECEIPT_SOURCE_MANIFEST_SHA256
    if ending:
        paths, ko_path, added, count, order = ENDING_PATHS, ENDING_KO_PATH, (), 21, "ORDER-473"
        receipt_paths, pins = ENDING_RECEIPT_PATHS, ENDING_RECEIPT_RAW_SHA256
        batches, source_manifest = ENDING_RECEIPT_BATCH_SHA256, ENDING_RECEIPT_SOURCE_MANIFEST_SHA256
    if first_win:
        paths, ko_path, added, count, order = FIRST_WIN_PATHS, FIRST_WIN_KO_PATH, (), 2, "ORDER-474"
        receipt_paths, pins = FIRST_WIN_RECEIPT_PATHS, FIRST_WIN_RECEIPT_RAW_SHA256
        batches, source_manifest = FIRST_WIN_RECEIPT_BATCH_SHA256, FIRST_WIN_RECEIPT_SOURCE_MANIFEST_SHA256
    if night:
        paths, ko_path, added, count, order = NIGHT_PATHS, NIGHT_KO_PATH, (), 2, "ORDER-475"
        receipt_paths, pins = NIGHT_RECEIPT_PATHS, NIGHT_RECEIPT_RAW_SHA256
        batches, source_manifest = NIGHT_RECEIPT_BATCH_SHA256, NIGHT_RECEIPT_SOURCE_MANIFEST_SHA256
    if loss_hold:
        paths, ko_path, added, count, order = LOSS_HOLD_PATHS, LOSS_HOLD_KO_PATH, (), 1, "ORDER-477"
        receipt_paths, pins = LOSS_HOLD_RECEIPT_PATHS, LOSS_HOLD_RECEIPT_RAW_SHA256
        batches, source_manifest = LOSS_HOLD_RECEIPT_BATCH_SHA256, LOSS_HOLD_RECEIPT_SOURCE_MANIFEST_SHA256
    _require(len(selectors) == count and set(pins) == set(receipt_paths)
             and set(batches) == set(LOCALES), "receipt pin/selector populations")
    for path in before:
        if path in receipt_paths:
            _require((_sha(before[path]), _sha(after[path])) == pins[path], "receipt raw " + path)
        else:
            _require(before[path] == after[path], "receipt changed a source/protected file")
    for path in (() if ending or first_win or night or loss_hold else PROSE_PATHS[10:] if prose else paths[2:]):
        if prose:
            prose_receipt_overlay_inverse(before[path], after[path], path)
        elif person:
            person_receipt_overlay_inverse(before[path], after[path], path)
        else:
            receipt_overlay_inverse(before[path], after[path], path, selectors)
    old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
    expected = copy.deepcopy(old)
    ko = {row["id"]: row for path in (PROSE_KO_PATHS if prose else (ko_path,)) for row in _loads(after[path])}
    source_paths = ({eid: "content/events/" + name + ".json" for name, eid, _keys in PROSE_SELECTORS}
                    if prose else {})
    group = "endings" if ending else "events"
    ids = {group + ":" + eid + ":/" + "/".join(map(str, keys)): (eid, keys) for eid, keys in selectors}
    new_ids = {group + ":" + eid + ":/" + "/".join(map(str, keys)) for eid, keys in added}
    _require(new["batches"][:len(old["batches"])] == old["batches"]
             and len(new["batches"]) == len(old["batches"]) + 3, "exact old batch prefix plus three official imports")
    seen, revisions = set(), []
    for batch in new["batches"][len(old["batches"]):]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(type(headers) is dict and len(headers) == 1, "one official locale per batch")
        locale = next(iter(headers))
        _require(locale in LOCALES and locale not in seen and _digest(batch) == batches[locale],
                 "exact official receipt batch")
        seen.add(locale)
        target_paths = (tuple("content/events_" + locale + "/" + name + ".json" for name in PROSE_NAMES)
                        if prose else (paths[2 + LOCALES.index(locale)],))
        targets_before, targets_after = ({row["id"]: row for path in target_paths for row in _loads(snapshot[path])}
                                        for snapshot in (before, after))
        rows, receipts = [], {}
        for identifier, (eid, keys) in sorted(ids.items()):
            ko_path = source_paths[eid] if prose else ko_path
            path = (ko_path.replace("content/events/", "content/events_" + locale + "/")
                    if prose else target_paths[0])
            source, target = _leaf(ko[eid], keys), _leaf(targets_after[eid], keys)
            source_hash = _digest({"path": ko_path, "field": keys, "ko": source})
            receipts[identifier] = {"source_sha256": source_hash, "target_sha256": _digest(target)}
            _require((identifier not in old["accepted"][locale]) == (identifier in new_ids),
                     "exact two first receipts and owned corrections per locale")
            if identifier not in new_ids:
                _require(old["accepted"][locale][identifier] != receipts[identifier], "correction was already current")
            expected["accepted"][locale][identifier] = receipts[identifier]
            rows.append({"group": group, "owner": eid, "source_path": ko_path, "path": list(keys),
                         "source": source, "category": "ending" if ending else "event_standard",
                         "lifecycle": "not_applicable" if ending else "shipping",
                         "protected": False, "runtime_support": "builtin_overlay_static_only",
                         "format_template": False, "id": identifier, "source_sha256": source_hash,
                         "locale": locale, "prompt_version": old["prompt_version"], "target_path": path,
                         "previous_target_sha256": _digest(_leaf(targets_before[eid], keys))})
        header = headers[locale]
        rebuilt = {"kind": "full_game_localization_batch", "schema_version": 1, "locale": locale,
                   "source_revision": header.get("source_revision"), "prompt_version": old["prompt_version"],
                   "source_manifest_sha256": source_manifest,
                   "selection_sha256": _digest(rows), "count": count, "source_language": "ko", "native_review": "OPEN"}
        rebuilt["batch_id"] = _digest(rebuilt)
        _require(header == rebuilt, "official export source/selection/old target binding")
        _require(batch.get("group") == group and batch.get("order") == order
                 and batch.get("source_leaves") == count and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN",
                 "machine acceptance is not human approval")
        counts = batch.get("target_leaves_by_locale", {})
        _require(set(counts) <= set(LOCALES) and all(counts.get(loc, 0) == (count if loc == locale else 0)
                                                   for loc in LOCALES), "receipt exact locale leaf census")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": receipts}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)}, "actual official receipt digest")
        revisions.append(header["source_revision"])
    _require(seen == set(LOCALES), "complete official locale acceptance")
    expected["accepted_sha256"] = _digest(expected["accepted"])
    expected["batches"] = new["batches"]
    _require(_ordered(new) == _ordered(expected), "receipt successor exceeds exact first/corrected leaves: " + order)
    return tuple(dict.fromkeys(revisions))


def _receipt_exports(before, revisions, root):
    """Typed export objects and ancestry stay fresh on every admission edge."""
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "export revision source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", revision, RECEIPT_COMMIT)


def _validate_receipts(before, after, source_before, root):
    # Preserve the direct API's complete immutable proof (including negatives).
    try:
        _receipt_exports(before, _receipt_semantics(before, after, source_before), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _person_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "person-deal export source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", revision, PERSON_RECEIPT_COMMIT)


def _validate_person_receipts(before, after, root):
    try:
        _person_receipt_exports(before, _person_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _prose_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "recall export source/target/ledger differs")
        _git(root, "merge-base", "--is-ancestor", revision, PROSE_RECEIPT_COMMIT)


def _validate_prose_receipts(before, after, root):
    try:
        _prose_receipt_exports(before, _prose_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _ending_ledger_inverse(before, after):
    """Only63 existing receipt pairs and the three appended batches may move."""
    return _correction_ledger_inverse(before, after, "endings", ENDING_TEXT_LEAVES, 261)


def _correction_ledger_inverse(before, after, group, selectors, prefix):
    """Literal-only inverse shared by the three named ledger-only corrections."""
    _require((group, selectors, prefix) in (("endings", ENDING_TEXT_LEAVES, 261),
                                          ("events", FIRST_WIN_TEXT_LEAVES, 264),
                                          ("events", NIGHT_TEXT_LEAVES, 267),
                                          ("events", LOSS_HOLD_TEXT_LEAVES, 270)),
             "unowned correction literal contract")
    old, new = _Document(before), _Document(after)
    old_batches, new_batches = old.value["batches"], new.value["batches"]
    _require(len(old_batches) == prefix and len(new_batches) == prefix + 3
             and new_batches[:prefix] == old_batches, "exact original correction batch prefix")
    start, _ = old.spans[("batches",)]
    next_start, _ = new.spans[("batches",)]
    _require(old.text[start:old.spans[("batches", prefix - 1)][1]]
             == new.text[next_start:new.spans[("batches", prefix - 1)][1]], "raw correction batch prefix changed")
    replacements = []
    for locale in LOCALES:
        _require(set(old.value["accepted"][locale]) == set(new.value["accepted"][locale]),
                 "ending receipt key population changed")
        for eid, keys in selectors:
            identifier = group + ":" + eid + ":/" + "/".join(map(str, keys))
            for field in ("source_sha256", "target_sha256"):
                key = ("accepted", locale, identifier, field)
                a, z = old.spans[key]
                b, end = new.spans[key]
                replacements.append((b, end, old.text[a:z]))
    for key in (("accepted_sha256",), ("batches",)):
        a, z = old.spans[key]
        b, end = new.spans[key]
        replacements.append((b, end, old.text[a:z]))
    restored = new.text
    for a, z, text in sorted(replacements, reverse=True):
        restored = restored[:a] + text + restored[z:]
    _require(restored.encode() == before, "ending ledger bytes changed outside owned receipts/append")
    return before


def _loss_hold_receipt_semantics(before, after):
    _require(LOSS_HOLD_PRODUCT_COMMIT is not None, "loss-hold receipts require authored source")
    revisions = _event_receipt_semantics(before, after, LOSS_HOLD_TEXT_LEAVES, person=False, loss_hold=True)
    _correction_ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH], "events", LOSS_HOLD_TEXT_LEAVES, 270)
    return revisions


def _loss_hold_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "loss-hold export source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", LOSS_HOLD_PRODUCT_COMMIT, revision)
        _git(root, "merge-base", "--is-ancestor", revision, LOSS_HOLD_RECEIPT_COMMIT)


def _validate_loss_hold_receipts(before, after, root):
    try:
        _loss_hold_receipt_exports(before, _loss_hold_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _loss_hold_stages(root, head, prior):
    """477 source5, ledger1 and optional measured metadata2 remain distinct."""
    _require(LOSS_HOLD_PRODUCT_COMMIT is not None and NIGHT_METADATA_COMMIT is not None
             and LOSS_HOLD_PATHS == NIGHT_PATHS
             and set(LOSS_HOLD_RAW_SHA256) == set(LOSS_HOLD_RAW_PATCHES) == set(LOSS_HOLD_PATHS),
             "loss-hold complete actual source pins")
    source = _ending_snapshot(root, head, prior, LOSS_HOLD_PRODUCT_PARENT, LOSS_HOLD_PRODUCT_COMMIT,
                              LOSS_HOLD_PATHS, NIGHT_METADATA_COMMIT)
    for path in LOSS_HOLD_PATHS:
        _memoized_semantics("loss-hold-product:" + path, (prior[path], source[path]),
                            lambda p=path: loss_hold_product_inverse(prior[p], source[p], p))
    accepted, metadata = None, None
    if LOSS_HOLD_RECEIPT_COMMIT is not None:
        accepted = _ending_snapshot(root, head, source, LOSS_HOLD_RECEIPT_PARENT, LOSS_HOLD_RECEIPT_COMMIT,
                                    LOSS_HOLD_RECEIPT_PATHS, LOSS_HOLD_PRODUCT_COMMIT)
        inputs = tuple((path, source[path], accepted[path]) for path in source)
        revisions = _memoized_semantics("loss-hold-receipts", inputs,
                                       lambda: _loss_hold_receipt_semantics(source, accepted))
        _loss_hold_receipt_exports(source, revisions, root)
    else:
        _require(LOSS_HOLD_RECEIPT_PARENT is None and not LOSS_HOLD_RECEIPT_RAW_SHA256
                 and not LOSS_HOLD_RECEIPT_BATCH_SHA256 and LOSS_HOLD_RECEIPT_SOURCE_MANIFEST_SHA256 is None,
                 "loss-hold unbound receipt pins")
    if LOSS_HOLD_METADATA_COMMIT is not None:
        _require(accepted is not None and LOSS_HOLD_METADATA_PATHS == (INVENTORY_PATH, RATING_PATH)
                 and set(LOSS_HOLD_METADATA_RAW_SHA256) == set(LOSS_HOLD_METADATA_RAW_PATCHES) == set(LOSS_HOLD_METADATA_PATHS),
                 "loss-hold metadata requires actual receipts and complete two-path pins")
        metadata = _ending_snapshot(root, head, accepted, LOSS_HOLD_METADATA_PARENT, LOSS_HOLD_METADATA_COMMIT,
                                    LOSS_HOLD_METADATA_PATHS, LOSS_HOLD_RECEIPT_COMMIT)
        for path in LOSS_HOLD_METADATA_PATHS:
            _memoized_semantics("loss-hold-metadata:" + path, (accepted[path], metadata[path]),
                                lambda p=path: loss_hold_metadata_inverse(accepted[p], metadata[p], p))
    else:
        _require(LOSS_HOLD_METADATA_PARENT is None and not LOSS_HOLD_METADATA_RAW_SHA256
                 and not LOSS_HOLD_METADATA_RAW_PATCHES, "loss-hold unbound metadata pins")
    return prior, source, accepted, metadata


def _night_receipt_semantics(before, after):
    _require(NIGHT_PRODUCT_COMMIT is not None, "night receipts require actual authored source")
    revisions = _event_receipt_semantics(before, after, NIGHT_TEXT_LEAVES, person=False, night=True)
    _correction_ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH], "events", NIGHT_TEXT_LEAVES, 267)
    return revisions


def _night_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "night export source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", NIGHT_PRODUCT_COMMIT, revision)
        _git(root, "merge-base", "--is-ancestor", revision, NIGHT_RECEIPT_COMMIT)


def _validate_night_receipts(before, after, root):
    try:
        _night_receipt_exports(before, _night_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _night_stages(root, head, prior):
    """Exactly source5 then ledger1, preserving474's completed receipt endpoint."""
    if NIGHT_PRODUCT_COMMIT is None:
        _require(NIGHT_RECEIPT_COMMIT is None, "night receipts lack actual authored source")
        return prior, None, None
    _require(FIRST_WIN_RECEIPT_COMMIT is not None and set(NIGHT_PATHS) <= set(prior)
             and set(NIGHT_RAW_SHA256) == set(NIGHT_RAW_PATCHES) == set(NIGHT_PATHS),
             "night complete source5 pins and predecessor")
    source = _ending_snapshot(root, head, prior, NIGHT_PRODUCT_PARENT, NIGHT_PRODUCT_COMMIT,
                              NIGHT_PATHS, FIRST_WIN_RECEIPT_COMMIT)
    for path in NIGHT_PATHS:
        _memoized_semantics("night-product:" + path, (prior[path], source[path]),
                            lambda p=path: night_routine_product_inverse(prior[p], source[p], p))
    accepted = None
    if NIGHT_RECEIPT_COMMIT is not None:
        accepted = _ending_snapshot(root, head, source, NIGHT_RECEIPT_PARENT, NIGHT_RECEIPT_COMMIT,
                                    NIGHT_RECEIPT_PATHS, NIGHT_PRODUCT_COMMIT)
        inputs = tuple((path, source[path], accepted[path]) for path in source)
        revisions = _memoized_semantics("night-receipts", inputs, lambda: _night_receipt_semantics(source, accepted))
        _night_receipt_exports(source, revisions, root)
    return prior, source, accepted


def _first_win_receipt_semantics(before, after):
    _require(FIRST_WIN_REPAIR_COMMIT is not None, "first-win receipts require actual repaired source")
    revisions = _event_receipt_semantics(before, after, FIRST_WIN_TEXT_LEAVES,
                                         person=False, first_win=True)
    _correction_ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH], "events", FIRST_WIN_TEXT_LEAVES, 264)
    return revisions


def _first_win_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "first-win export source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", FIRST_WIN_REPAIR_COMMIT, revision)
        _git(root, "merge-base", "--is-ancestor", revision, FIRST_WIN_RECEIPT_COMMIT)


def _validate_first_win_receipts(before, after, root):
    try:
        _first_win_receipt_exports(before, _first_win_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _first_win_stages(root, head, prior):
    """Source5, exact Korean notation1, then ledger1 follow immutable473."""
    if FIRST_WIN_PRODUCT_COMMIT is None:
        _require(FIRST_WIN_REPAIR_COMMIT is FIRST_WIN_RECEIPT_COMMIT is None,
                 "first-win repair/receipts lack actual authored source")
        return prior, None, None, None
    _require(ENDING_METADATA_COMMIT is not None and set(FIRST_WIN_PATHS) <= set(prior)
             and set(FIRST_WIN_RAW_SHA256) == set(FIRST_WIN_RAW_PATCHES) == set(FIRST_WIN_PATHS),
             "first-win complete source5 pins and predecessor")
    initial = _ending_snapshot(root, head, prior, FIRST_WIN_PRODUCT_PARENT, FIRST_WIN_PRODUCT_COMMIT,
                               FIRST_WIN_PATHS, ENDING_METADATA_COMMIT)
    for path in FIRST_WIN_PATHS:
        _memoized_semantics("first-win-product:" + path, (prior[path], initial[path]),
                            lambda p=path: first_win_product_inverse(prior[p], initial[p], p))
    source = initial
    if FIRST_WIN_REPAIR_COMMIT is not None:
        _require(FIRST_WIN_REPAIR_PATHS == (FIRST_WIN_KO_PATH,)
                 and set(FIRST_WIN_REPAIR_RAW_SHA256) == set(FIRST_WIN_REPAIR_RAW_PATCHES) == set(FIRST_WIN_REPAIR_PATHS),
                 "first-win complete Korean repair1 pins")
        source = _ending_snapshot(root, head, initial, FIRST_WIN_REPAIR_PARENT, FIRST_WIN_REPAIR_COMMIT,
                                   FIRST_WIN_REPAIR_PATHS, FIRST_WIN_PRODUCT_COMMIT)
        path = FIRST_WIN_KO_PATH
        _memoized_semantics("first-win-repair:" + path, (initial[path], source[path]),
                            lambda: first_win_product_inverse(initial[path], source[path], path, repair=True))
    accepted = None
    if FIRST_WIN_RECEIPT_COMMIT is not None:
        _require(FIRST_WIN_REPAIR_COMMIT is not None, "first-win receipts lack actual Korean repair")
        accepted = _ending_snapshot(root, head, source, FIRST_WIN_RECEIPT_PARENT, FIRST_WIN_RECEIPT_COMMIT,
                                    FIRST_WIN_RECEIPT_PATHS, FIRST_WIN_REPAIR_COMMIT)
        inputs = tuple((path, source[path], accepted[path]) for path in source)
        revisions = _memoized_semantics("first-win-receipts", inputs,
                                       lambda: _first_win_receipt_semantics(source, accepted))
        _first_win_receipt_exports(source, revisions, root)
    return prior, initial, source, accepted


def _ending_receipt_semantics(before, after):
    _require(ENDING_REPAIR_COMMIT is not None, "ending receipt requires final authored source")
    revisions = _event_receipt_semantics(before, after, ENDING_TEXT_LEAVES,
                                         person=False, ending=True)
    _ending_ledger_inverse(before[LEDGER_PATH], after[LEDGER_PATH])
    return revisions


def _ending_receipt_exports(before, revisions, root):
    for revision in revisions:
        export, _ = _snapshot(root, revision, tuple(before))
        _require(export == before, "ending export source/draft/ledger differs")
        _git(root, "merge-base", "--is-ancestor", ENDING_REPAIR_COMMIT, revision)
        _git(root, "merge-base", "--is-ancestor", revision, ENDING_RECEIPT_COMMIT)


def _validate_ending_receipts(before, after, root):
    try:
        _ending_receipt_exports(before, _ending_receipt_semantics(before, after), root)
    except BaseException:
        memo = _SEMANTIC_MEMO.get()
        if memo is not None:
            memo[1].clear()
        raise


def _ending_snapshot(root, head, prior, parent, commit, changed, ancestor):
    """Typed direct-parent edge for the named finite money-fact stages."""
    before, _ = _snapshot(root, parent, tuple(prior))
    after, headers = _snapshot(root, commit, tuple(prior))
    _require(before == prior, "ending stage predecessor differs")
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [parent],
             "ending exact direct parent")
    expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(changed))
    _require(_git(root, "diff", "--name-status", "-z", parent, commit) == expected,
             "ending exact changed path population")
    _git(root, "merge-base", "--is-ancestor", ancestor, commit)
    _git(root, "merge-base", "--is-ancestor", commit, head)
    _require(all(before[p] == after[p] for p in before if p not in changed),
             "ending stage changed unowned source/target/receipt/metadata")
    return after


def _ending_stages(root, head, prior):
    paths = tuple(dict.fromkeys((*prior, *ENDING_PATHS)))
    before, _ = _snapshot(root, ENDING_PRODUCT_PARENT, paths)
    _require({path: before[path] for path in prior} == prior,
             "ending predecessor must preserve exact472 metadata endpoint")
    if ENDING_PRODUCT_COMMIT is None:
        _require(ENDING_REPAIR_COMMIT is ENDING_RECEIPT_COMMIT is ENDING_METADATA_COMMIT is None,
                 "unbound ending source cannot have successors")
        return before, None, None, None, None
    initial = _ending_snapshot(root, head, before, ENDING_PRODUCT_PARENT, ENDING_PRODUCT_COMMIT,
                               ENDING_PATHS, PROSE_METADATA_COMMIT)
    _require(set(ENDING_RAW_SHA256) == set(ENDING_RAW_PATCHES) == set(ENDING_PATHS),
             "ending complete source5 pins")
    for path in ENDING_PATHS:
        _memoized_semantics("ending-product:" + path, (before[path], initial[path]),
                            lambda p=path: ending_product_inverse(before[p], initial[p], p))
    source = initial
    if ENDING_REPAIR_COMMIT is not None:
        source = _ending_snapshot(root, head, initial, ENDING_REPAIR_PARENT, ENDING_REPAIR_COMMIT,
                                  ENDING_REPAIR_PATHS, ENDING_PRODUCT_COMMIT)
        _require(ENDING_REPAIR_PARENT == ENDING_PRODUCT_COMMIT
                 and set(ENDING_REPAIR_RAW_SHA256) == set(ENDING_REPAIR_RAW_PATCHES) == set(ENDING_REPAIR_PATHS),
                 "ending complete repair pins")
        for path in ENDING_REPAIR_PATHS:
            _memoized_semantics("ending-repair:" + path, (initial[path], source[path]),
                                lambda p=path: ending_product_inverse(initial[p], source[p], p, repair=True))
    accepted = metadata = None
    if ENDING_RECEIPT_COMMIT is not None:
        _require(ENDING_REPAIR_COMMIT is not None, "ending receipts lack source repair")
        accepted = _ending_snapshot(root, head, source, ENDING_RECEIPT_PARENT, ENDING_RECEIPT_COMMIT,
                                    ENDING_RECEIPT_PATHS, ENDING_REPAIR_COMMIT)
        inputs = tuple((path, source[path], accepted[path]) for path in paths)
        revisions = _memoized_semantics("ending-receipts", inputs,
                                       lambda: _ending_receipt_semantics(source, accepted))
        _ending_receipt_exports(source, revisions, root)
    if ENDING_METADATA_COMMIT is not None:
        _require(accepted is not None, "ending metadata requires completed63 receipts")
        metadata = _ending_snapshot(root, head, accepted, ENDING_METADATA_PARENT, ENDING_METADATA_COMMIT,
                                    ENDING_METADATA_PATHS, ENDING_RECEIPT_COMMIT)
        _require(set(ENDING_METADATA_RAW_SHA256) == set(ENDING_METADATA_RAW_PATCHES) == set(ENDING_METADATA_PATHS),
                 "ending complete metadata2 pins")
        for path in ENDING_METADATA_PATHS:
            _memoized_semantics("ending-metadata:" + path, (accepted[path], metadata[path]),
                                lambda p=path: ending_metadata_inverse(accepted[p], metadata[p], p))
    return before, initial, source, accepted, metadata


def _prose_stages(root, head, prior):
    """Exact source10 then receipt16; earlier42/18 endpoints remain immutable."""
    if PROSE_PRODUCT_COMMIT is None:
        _require(PROSE_RECEIPT_COMMIT is None, "recall receipts lack authored source")
        return None, None, None
    _require(PERSON_RECEIPT_COMMIT is not None, "recall source requires completed471 receipts")
    paths = tuple(dict.fromkeys((*prior, *PROSE_PATHS)))
    before, _ = _snapshot(root, PROSE_PRODUCT_PARENT, paths)
    source, headers = _snapshot(root, PROSE_PRODUCT_COMMIT, paths)
    _require({path: before[path] for path in prior} == prior,
             "recall predecessor must preserve exact471 receipt endpoint")
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PROSE_PRODUCT_PARENT],
             "recall exact source direct parent")
    expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(PROSE_PRODUCT_PATHS))
    _require(_git(root, "diff", "--name-status", "-z", PROSE_PRODUCT_PARENT, PROSE_PRODUCT_COMMIT)
             == expected, "recall exact ten source paths")
    _git(root, "merge-base", "--is-ancestor", PERSON_RECEIPT_COMMIT, PROSE_PRODUCT_COMMIT)
    _git(root, "merge-base", "--is-ancestor", PROSE_PRODUCT_COMMIT, head)
    _require(len(PROSE_TEXT_LEAVES) == len(set(PROSE_TEXT_LEAVES)) == 40
             and len(PROSE_SELECTORS) == 8 and len(PROSE_PRODUCT_PATHS) == 10
             and set(PROSE_RAW_SHA256) == set(PROSE_RAW_PATCHES) == set(PROSE_PRODUCT_PATHS),
             "recall exact scene/leaf/path/pin populations")
    for path in paths:
        if path in PROSE_PRODUCT_PATHS:
            _memoized_semantics("prose-product:" + path, (before[path], source[path]),
                                lambda p=path: prose_product_inverse(before[p], source[p], p))
        else:
            _require(before[path] == source[path], "recall source changed target/protected file or receipts")
    accepted = None
    if PROSE_RECEIPT_COMMIT is not None:
        receipt_before, _ = _snapshot(root, PROSE_RECEIPT_PARENT, paths)
        accepted, headers = _snapshot(root, PROSE_RECEIPT_COMMIT, paths)
        _require(receipt_before == source, "recall receipt parent differs from exact source10")
        _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PROSE_RECEIPT_PARENT],
                 "recall exact receipt direct parent")
        expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(PROSE_RECEIPT_PATHS))
        _require(_git(root, "diff", "--name-status", "-z", PROSE_RECEIPT_PARENT, PROSE_RECEIPT_COMMIT)
                 == expected, "recall exact sixteen receipt paths")
        _git(root, "merge-base", "--is-ancestor", PROSE_PRODUCT_COMMIT, PROSE_RECEIPT_COMMIT)
        _git(root, "merge-base", "--is-ancestor", PROSE_RECEIPT_COMMIT, head)
        inputs = tuple((path, source[path], accepted[path]) for path in paths)
        revisions = _memoized_semantics("prose-receipts", inputs,
                                       lambda: _prose_receipt_semantics(source, accepted))
        _prose_receipt_exports(source, revisions, root)
    return before, source, accepted


def _person_stages(root, head, prior):
    """Exact source5 then receipt4, retaining the original470 receipt endpoint."""
    if PERSON_PRODUCT_COMMIT is None:
        _require(PERSON_RECEIPT_COMMIT is None, "person-deal receipts lack authored source")
        return None, None, None
    _require(RECEIPT_COMMIT is not None, "person-deal source requires completed470 receipts")
    paths = tuple(dict.fromkeys((*prior, *PERSON_PRODUCT_PATHS)))
    before, _ = _snapshot(root, PERSON_PRODUCT_PARENT, paths)
    source, headers = _snapshot(root, PERSON_PRODUCT_COMMIT, paths)
    _require({path: before[path] for path in prior} == prior,
             "person-deal predecessor must preserve exact470 R4")
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PERSON_PRODUCT_PARENT],
             "person-deal exact source direct parent")
    expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(PERSON_PRODUCT_PATHS))
    _require(_git(root, "diff", "--name-status", "-z", PERSON_PRODUCT_PARENT, PERSON_PRODUCT_COMMIT)
             == expected, "person-deal exact five source paths")
    _git(root, "merge-base", "--is-ancestor", RECEIPT_COMMIT, PERSON_PRODUCT_COMMIT)
    _git(root, "merge-base", "--is-ancestor", PERSON_PRODUCT_COMMIT, head)
    _require(set(PERSON_RAW_SHA256) == set(PERSON_RAW_PATCHES) == set(PERSON_PRODUCT_PATHS),
             "person-deal complete source pins")
    for path in paths:
        if path in PERSON_PRODUCT_PATHS:
            _memoized_semantics("person-product:" + path, (before[path], source[path]),
                                lambda p=path: person_product_inverse(before[p], source[p], p))
        else:
            _require(before[path] == source[path], "person-deal source changed protected file or receipts")
    accepted = None
    if PERSON_RECEIPT_COMMIT is not None:
        receipt_before, _ = _snapshot(root, PERSON_RECEIPT_PARENT, paths)
        accepted, headers = _snapshot(root, PERSON_RECEIPT_COMMIT, paths)
        _require(receipt_before == source, "person-deal receipt parent differs from source5/draft")
        _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PERSON_RECEIPT_PARENT],
                 "person-deal exact receipt direct parent")
        expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(PERSON_RECEIPT_PATHS))
        _require(_git(root, "diff", "--name-status", "-z", PERSON_RECEIPT_PARENT, PERSON_RECEIPT_COMMIT)
                 == expected, "person-deal exact four receipt paths")
        _git(root, "merge-base", "--is-ancestor", PERSON_PRODUCT_COMMIT, PERSON_RECEIPT_COMMIT)
        _git(root, "merge-base", "--is-ancestor", PERSON_RECEIPT_COMMIT, head)
        inputs = tuple((path, source[path], accepted[path]) for path in paths)
        revisions = _memoized_semantics("person-receipts", inputs,
                                       lambda: _person_receipt_semantics(source, accepted))
        _person_receipt_exports(source, revisions, root)
    return before, source, accepted


def _prose_metadata_stage(root, head, prior):
    """One pinned two-file metadata successor, not another receipt endpoint."""
    if PROSE_METADATA_COMMIT is None:
        return None
    _require(PROSE_RECEIPT_COMMIT is not None, "recall metadata requires its completed receipt stage")
    before, _ = _snapshot(root, PROSE_METADATA_PARENT, tuple(prior))
    after, headers = _snapshot(root, PROSE_METADATA_COMMIT, tuple(prior))
    _require(before == prior, "metadata predecessor differs from exact472 source/receipt endpoint")
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PROSE_METADATA_PARENT],
             "exact metadata direct parent")
    expected = b"".join(b"M\0" + path.encode() + b"\0" for path in sorted(PROSE_METADATA_PATHS))
    _require(_git(root, "diff", "--name-status", "-z", PROSE_METADATA_PARENT, PROSE_METADATA_COMMIT)
             == expected, "exact two metadata paths")
    _git(root, "merge-base", "--is-ancestor", PROSE_RECEIPT_COMMIT, PROSE_METADATA_COMMIT)
    _git(root, "merge-base", "--is-ancestor", PROSE_METADATA_COMMIT, head)
    _require(set(PROSE_METADATA_RAW_SHA256) == set(PROSE_METADATA_RAW_PATCHES) == set(PROSE_METADATA_PATHS),
             "complete metadata raw/hunk pins")
    for path in prior:
        if path in PROSE_METADATA_PATHS:
            _memoized_semantics("prose-metadata:" + path, (before[path], after[path]),
                                lambda p=path: prose_metadata_inverse(before[p], after[p], p))
        else:
            _require(before[path] == after[path], "metadata changed source/target/receipt/protected raw")
    return after


def _night_metadata_stage(root, head, prior):
    if NIGHT_METADATA_COMMIT is None:
        return None
    _require(NIGHT_RECEIPT_COMMIT is not None
             and NIGHT_METADATA_PATHS == (INVENTORY_PATH, RATING_PATH)
             and set(NIGHT_METADATA_RAW_SHA256) == set(NIGHT_METADATA_RAW_PATCHES) == set(NIGHT_METADATA_PATHS),
             "night metadata requires completed receipts and exact two-file pins")
    after = _ending_snapshot(root, head, prior, NIGHT_METADATA_PARENT, NIGHT_METADATA_COMMIT,
                             NIGHT_METADATA_PATHS, NIGHT_RECEIPT_COMMIT)
    for path in NIGHT_METADATA_PATHS:
        _memoized_semantics("night-metadata:" + path, (prior[path], after[path]),
                            lambda p=path: night_metadata_inverse(prior[p], after[p], p))
    return after


def _read_proof(root):
    """Fresh current/immutable admission, with invocation-local pure reuse."""
    memo = _SEMANTIC_MEMO.get()
    try:
        binding = _semantic_binding(root)
        if memo is not None:
            _require(binding == memo[0], "semantic scope root/config/module identity changed")
        proof = _read_proof_current(root)
        _require(_semantic_binding(root) == binding, "proof configuration/module changed during read")
        return proof
    except BaseException:
        if memo is not None:
            memo[1].clear()
        raise


def _read_proof_current(root):
    root = Path(root).resolve()
    head = _git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip()
    before, _ = _snapshot(root, PRODUCT_PARENT, (*PRODUCT_PATHS, LEDGER_PATH))
    after, headers = _snapshot(root, PRODUCT_COMMIT, (*PRODUCT_PATHS, LEDGER_PATH))
    _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [PRODUCT_PARENT],
             "exact source product parent")
    expected = b"".join(b"M\0" + p.encode() + b"\0" for p in sorted(PRODUCT_PATHS))
    _require(_git(root, "diff", "--name-status", "-z", PRODUCT_PARENT, PRODUCT_COMMIT) == expected,
             "exact nine modified source paths")
    _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, head)
    _require(set(RAW_SHA256) == set(PRODUCT_PATHS), "complete source raw pins")
    _require(before[LEDGER_PATH] == after[LEDGER_PATH], "source draft is not translation acceptance")
    for path in PRODUCT_PATHS:
        _require((_sha(before[path]), _sha(after[path])) == RAW_SHA256.get(path), "source raw pin " + path)
    current, receipts = after, None
    if RECEIPT_COMMIT is not None:
        receipt_before, _ = _snapshot(root, RECEIPT_PARENT, tuple(after))
        receipts, headers = _snapshot(root, RECEIPT_COMMIT, tuple(after))
        _require(receipt_before == after, "receipt predecessor must preserve whole source9 and old ledger")
        _require([h[7:].decode() for h in headers if h.startswith(b"parent ")] == [RECEIPT_PARENT],
                 "exact receipt direct parent")
        changed = b"".join(b"M\0" + p.encode() + b"\0" for p in sorted(RECEIPT_PATHS))
        _require(_git(root, "diff", "--name-status", "-z", RECEIPT_PARENT, RECEIPT_COMMIT) == changed,
                 "exact four receipt/target paths")
        _git(root, "merge-base", "--is-ancestor", PRODUCT_COMMIT, RECEIPT_COMMIT)
        _git(root, "merge-base", "--is-ancestor", RECEIPT_COMMIT, head)
        _require(set(RECEIPT_RAW_SHA256) == set(RECEIPT_PATHS), "receipt raw pin population")
        for path in RECEIPT_PATHS:
            _require((_sha(receipt_before[path]), _sha(receipts[path])) == RECEIPT_RAW_SHA256[path],
                     "receipt raw pin " + path)
        current = receipts
    person_before, person_source, person_receipts = _person_stages(root, head, current)
    if person_source is not None:
        current = person_receipts if person_receipts is not None else person_source
    prose_before, prose_source, prose_receipts = _prose_stages(root, head, current)
    if prose_source is not None:
        current = prose_receipts if prose_receipts is not None else prose_source
    prose_current = current
    prose_metadata = _prose_metadata_stage(root, head, current)
    if prose_metadata is not None:
        current = prose_metadata
    ending_before, ending_initial, ending_source, ending_receipts, ending_metadata = _ending_stages(root, head, current)
    current = (ending_metadata if ending_metadata is not None else ending_receipts if ending_receipts is not None
               else ending_source if ending_source is not None else ending_before)
    first_win_before, first_win_initial, first_win_source, first_win_receipts = _first_win_stages(root, head, current)
    current = (first_win_receipts if first_win_receipts is not None else first_win_source
               if first_win_source is not None else first_win_before)
    night_before, night_source, night_receipts = _night_stages(root, head, current)
    current = night_receipts if night_receipts is not None else night_source if night_source is not None else night_before
    night_metadata = _night_metadata_stage(root, head, current)
    if night_metadata is not None:
        current = night_metadata
    loss_hold_before, loss_hold_source, loss_hold_receipts, loss_hold_metadata = _loss_hold_stages(root, head, current)
    current = (loss_hold_metadata if loss_hold_metadata is not None else loss_hold_receipts
               if loss_hold_receipts is not None else loss_hold_source)
    #478's independent leaf proof owns Investment+JA and a separate first UI
    #receipt. Every earlier dictionary remains its immutable product endpoint.
    import market_cycle_label_history as market
    with market.fresh_validation_proof(root) as market_proof:
        _require(market_proof["head"] == head and current[LEDGER_PATH] == market_proof["before"][LEDGER_PATH],
                 "market successor must start at immutable477 ledger")
        market_before = dict(current)
        market_source = {**current, LEDGER_PATH: market_proof["source"][LEDGER_PATH]}
        market_receipts = (None if market_proof["receipts"] is None else
                           {**current, LEDGER_PATH: market_proof["receipts"][LEDGER_PATH]})
        current = market_source if market_receipts is None else market_receipts
    import wealth_milestone_log_history as wealth
    with wealth.fresh_validation_proof(root) as wealth_proof:
        owned = (wealth.GAME_STATE_PATH, LEDGER_PATH)
        _require(wealth_proof["head"] == head
                 and all(current[p] == wealth_proof["before"][p] for p in owned),
                 "wealth predecessor differs from immutable470/478 payload")
        wealth_before = dict(current)
        wealth_source = {**current, **{p: wealth_proof["source"][p] for p in owned}}
        wealth_receipts = (None if wealth_proof["receipts"] is None else
                           {**current, **{p: wealth_proof["receipts"][p] for p in owned}})
        wealth.product_inverse(current[wealth.GAME_STATE_PATH], wealth_source[wealth.GAME_STATE_PATH],
                               wealth.GAME_STATE_PATH)
        current = wealth_source if wealth_receipts is None else wealth_receipts
        _require(all(current[p] == wealth_proof["one_billion_before"][p] for p in owned),
                 "one-billion predecessor differs from immutable480 GS/ledger")
        one_billion_before = dict(current)
        one_billion_source = {**current, **{p: wealth_proof["one_billion_source"][p] for p in owned}}
        one_billion_receipts = (None if wealth_proof["one_billion_receipts"] is None else
                               {**current, **{p: wealth_proof["one_billion_receipts"][p] for p in owned}})
        current = one_billion_source if one_billion_receipts is None else one_billion_receipts
        _require(all(current[p] == wealth_proof["current"][p] for p in owned),
                 "one-billion actual GS/ledger differs")
    actual, _ = _snapshot(root, head, tuple(current))
    _require(actual == current, "current HEAD differs from exact source/receipt product")
    _require(all(_disk_bytes(root / p) == raw for p, raw in actual.items()), "current disk differs from Git")
    for path in PRODUCT_PATHS:
        _memoized_semantics("product:" + path, (before[path], after[path]),
                            lambda p=path: product_inverse(before[p], after[p], p))
    if receipts is not None:
        inputs = tuple((p, before[p], receipt_before[p], receipts[p]) for p in before)
        revisions = _memoized_semantics("receipts", inputs,
                                       lambda: _receipt_semantics(receipt_before, receipts, before))
        _receipt_exports(receipt_before, revisions, root)
    # A failure after successful pure work must clear that work too. Observe
    # the actual HEAD/disk again before returning, without historical views.
    _require(_git(root, "rev-parse", "--verify", "HEAD^{commit}").decode().strip() == head,
             "HEAD changed during proof")
    _require(all(_disk_bytes(root / p) == raw for p, raw in actual.items()), "disk changed during proof")
    return {"root": root, "head": head, "before": before, "after": after,
            "current": actual, "receipts": receipts, "person_before": person_before,
            "loss_hold_before": loss_hold_before, "loss_hold_source": loss_hold_source,
            "loss_hold_receipts": loss_hold_receipts, "loss_hold_metadata": loss_hold_metadata,
            "market_before": market_before, "market_source": market_source, "market_receipts": market_receipts,
            "wealth_before": wealth_before, "wealth_source": wealth_source, "wealth_receipts": wealth_receipts,
            "one_billion_before": one_billion_before, "one_billion_source": one_billion_source,
            "one_billion_receipts": one_billion_receipts,
            "person_source": person_source, "person_receipts": person_receipts,
            "prose_before": prose_before, "prose_source": prose_source, "prose_receipts": prose_receipts,
            "prose_current": prose_current, "prose_metadata": prose_metadata,
            "ending_before": ending_before, "ending_initial": ending_initial, "ending_source": ending_source,
            "ending_receipts": ending_receipts, "ending_metadata": ending_metadata,
            "first_win_before": first_win_before, "first_win_initial": first_win_initial,
            "first_win_source": first_win_source,
            "first_win_receipts": first_win_receipts,
            "night_before": night_before, "night_source": night_source, "night_receipts": night_receipts,
            "night_metadata": night_metadata,
            "binding": _configuration()}


@contextlib.contextmanager
def fresh_validation_proof(root=ROOT):
    active = _ACTIVE.get()
    if active is not None:
        try:
            _require(Path(root).resolve() == active["root"] and _read_proof(root) == active,
                     "nested proof Git/disk/configuration changed")
            yield active
            _require(_read_proof(root) == active, "nested proof changed during use")
        except BaseException:
            _SEMANTIC_MEMO.get()[1].clear()
            raise
        return
    memo = (_semantic_binding(root), {})
    memo_token = _SEMANTIC_MEMO.set(memo)
    try:
        proof = _read_proof(root)
        token = _ACTIVE.set(proof)
        try:
            yield proof
            _require(_read_proof(root) == proof, "Git/disk/configuration changed inside proof")
        finally:
            _ACTIVE.reset(token)
    finally:
        memo[1].clear()
        _SEMANTIC_MEMO.reset(memo_token)


def predecessor_bytes(raw, path, root=ROOT):
    with fresh_validation_proof(root) as proof:
        _require(path in PRODUCT_PATHS and type(raw) is bytes and raw == proof["current"][path],
                 "actual current raw differs: " + path)
        return proof["before"][path]


def source_predecessor_inventory(root, inventory):
    with fresh_validation_proof(root) as proof:
        hashes = inventory["source_hashes"]
        _require(type(hashes) is dict and _digest(hashes) == inventory["source_manifest_sha256"],
                 "actual source census digest")
        _require(all(hashes.get(p) == _sha(proof["current"][p]) for p in SOURCE_PATHS),
                 "actual three-source census binding")
        import wealth_milestone_log_history as wealth
        pre_wealth = wealth.source_predecessor_inventory(root, inventory)["source_hashes"]
        comparison = {**_person_source_comparison(root, proof, _prose_source_comparison(
                          root, proof, _ending_source_comparison(
                              root, proof, _first_win_source_comparison(
                                  root, proof, _night_source_comparison(root, proof, pre_wealth))))),
                      **{p: _sha(proof["before"][p]) for p in SOURCE_PATHS}}
        _require(_digest(comparison) == PREDECESSOR_SOURCE_MANIFEST_SHA256,
                 "exact pre470 complete source census")
        actual, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require({p: _sha(raw) for p, raw in actual.items()} == hashes
                 and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()),
                 "complete actual Git/disk source census")
        return {**inventory, "source_hashes": comparison, "source_manifest_sha256": _digest(comparison)}


def historical_loss_hold_comparison(raw_by_locale, root=ROOT):
    """Exact actual five raws -> immutable pre477 comparison, never runtime."""
    locales = ("ko", "en", *LOCALES)
    with fresh_validation_proof(root) as proof:
        _require(type(raw_by_locale) is dict and set(raw_by_locale) == set(locales),
                 "loss-hold exact five-locale population")
        _require(all(type(raw_by_locale[locale]) is bytes
                     and raw_by_locale[locale] == proof["current"][path]
                     for locale, path in zip(locales, LOSS_HOLD_PATHS)), "loss-hold actual current raw only")
        return {locale: proof["loss_hold_before"][path] for locale, path in zip(locales, LOSS_HOLD_PATHS)}


def _loss_hold_source_comparison(root, proof, hashes):
    """Project only477 KO before476 Main; independently bind the whole parent."""
    path = LOSS_HOLD_KO_PATH
    _require(type(hashes) is dict and hashes.get(path) == _sha(proof["loss_hold_source"][path]),
             "loss-hold actual Korean source census")
    comparison = {**hashes, path: _sha(proof["loss_hold_before"][path])}
    prior, _ = _snapshot(root, LOSS_HOLD_PRODUCT_PARENT, tuple(hashes))
    _require({p: _sha(raw) for p, raw in prior.items()} == comparison,
             "loss-hold exact whole predecessor census")
    return comparison


def historical_first_win_comparison(raw_by_locale, root=ROOT):
    """Exact current5 -> pre-night5 for the historical474 audit only."""
    locales = ("ko", "en", *LOCALES)
    with fresh_validation_proof(root) as proof:
        _require(NIGHT_PRODUCT_COMMIT is not None and proof["night_source"] is not None,
                 "historical first-win comparison requires actual night source")
        _require(type(raw_by_locale) is dict and set(raw_by_locale) == set(locales),
                 "historical first-win exact five-locale population")
        _require(all(type(raw_by_locale[locale]) is bytes
                     and raw_by_locale[locale] == proof["current"][path]
                     for locale, path in zip(locales, NIGHT_PATHS)),
                 "historical first-win comparison accepts current raw only")
        return {locale: proof["night_before"][path] for locale, path in zip(locales, NIGHT_PATHS)}


def _night_source_comparison(root, proof, hashes):
    """Current KO -> immutable474 census; never used as a runtime payload."""
    if proof["night_source"] is None:
        return dict(hashes)
    path = NIGHT_KO_PATH
    _require(hashes.get(path) == _sha(proof["night_source"][path]), "night actual source census binding")
    comparison = {**hashes, path: _sha(proof["night_before"][path])}
    _require(_digest(comparison) == FIRST_WIN_RECEIPT_SOURCE_MANIFEST_SHA256,
             "exact pre475 complete source census")
    prior, _ = _snapshot(root, NIGHT_PRODUCT_PARENT, tuple(hashes))
    _require({p: _sha(raw) for p, raw in prior.items()} == comparison,
             "night predecessor census differs outside exact Korean midgame source")
    return comparison


def _first_win_source_comparison(root, proof, hashes):
    """Current Korean notation -> initial474 -> immutable473 comparison census."""
    if proof["first_win_source"] is None:
        return dict(hashes)
    path = FIRST_WIN_KO_PATH
    _require(hashes.get(path) == _sha(proof["first_win_source"][path]), "first-win actual source census binding")
    # The fresh stage proof already typed the initial and repair snapshots;
    # retain both identities without another complete-census Git walk here.
    _require(_sha(proof["first_win_initial"][path]) == FIRST_WIN_RAW_SHA256[path][1],
             "first-win initial source census binding")
    initial = {**hashes, path: _sha(proof["first_win_initial"][path])}
    comparison = {**initial, path: _sha(proof["first_win_before"][path])}
    _require(_digest(comparison) == ENDING_RECEIPT_SOURCE_MANIFEST_SHA256,
             "exact pre474 complete source census")
    prior, _ = _snapshot(root, FIRST_WIN_PRODUCT_PARENT, tuple(hashes))
    _require({p: _sha(raw) for p, raw in prior.items()} == comparison,
             "first-win predecessor census differs outside exact Korean midgame source")
    return comparison


def _ending_source_comparison(root, proof, hashes):
    """Current source census -> immutable472 census; never a runtime prose view."""
    if proof["ending_source"] is None:
        return dict(hashes)
    path = ENDING_KO_PATH
    _require(hashes.get(path) == _sha(proof["ending_source"][path]), "ending actual source census binding")
    comparison = {**hashes, path: _sha(proof["ending_before"][path])}
    _require(_digest(comparison) == PROSE_RECEIPT_SOURCE_MANIFEST_SHA256,
             "exact pre473 complete source census")
    prior, _ = _snapshot(root, ENDING_PRODUCT_PARENT, tuple(hashes))
    _require({p: _sha(raw) for p, raw in prior.items()} == comparison,
             "ending predecessor census differs outside exact Korean ending source")
    return comparison


def _person_source_comparison(root, proof, hashes):
    """Current complete census -> exact470 census before its own source inverse."""
    if proof["person_before"] is None:
        return dict(hashes)
    path = PERSON_KO_PATH
    endpoint = proof["person_receipts"] if proof["person_receipts"] is not None else proof["person_source"]
    _require(hashes.get(path) == _sha(endpoint[path]), "person-deal actual source census binding")
    comparison = {**hashes, path: _sha(proof["person_before"][path])}
    _require(_digest(comparison) == RECEIPT_SOURCE_MANIFEST_SHA256, "exact pre471 complete source census")
    prior, _ = _snapshot(root, PERSON_PRODUCT_PARENT, tuple(hashes))
    _require({p: _sha(raw) for p, raw in prior.items()} == comparison,
             "person-deal predecessor census differs outside exact Korean theme source")
    return comparison


def _prose_source_comparison(root, proof, hashes):
    """Actual complete census -> the separately preserved471 source census."""
    if proof["prose_before"] is None:
        return dict(hashes)
    _require(all(hashes.get(path) == _sha(proof["prose_current"][path]) for path in PROSE_KO_PATHS),
             "recall immutable five-source census binding after newer inverses")
    comparison = {**hashes, **{path: _sha(proof["prose_before"][path]) for path in PROSE_KO_PATHS}}
    _require(_digest(comparison) == PERSON_RECEIPT_SOURCE_MANIFEST_SHA256,
             "exact pre472 complete source census")
    prior, _ = _snapshot(root, PROSE_PRODUCT_PARENT, tuple(hashes))
    _require({path: _sha(raw) for path, raw in prior.items()} == comparison,
             "recall predecessor census differs outside exact five Korean sources")
    return comparison
