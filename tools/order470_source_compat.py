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


def product_inverse(before, after, path):
    _require(path in PRODUCT_PATHS and type(before) is bytes and type(after) is bytes
             and (_sha(before), _sha(after)) == RAW_SHA256.get(path), "unapproved raw pair: " + path)
    from difflib import SequenceMatcher
    old_lines, new_lines = before.splitlines(True), after.splitlines(True)
    patches = []
    restored = list(new_lines)
    opcodes = SequenceMatcher(None, old_lines, new_lines, autojunk=False).get_opcodes()
    for tag, a, z, b, end in opcodes:
        if tag != "equal":
            patches.append((tag, a, z, b, end, _sha(b"".join(old_lines[a:z])),
                            _sha(b"".join(new_lines[b:end]))))
    _require(tuple(patches) == RAW_PATCHES.get(path), "exact raw hunk coordinates/bytes: " + path)
    for tag, a, z, b, end in reversed(opcodes):
        if tag != "equal":
            restored[b:end] = old_lines[a:z]
    _require(b"".join(restored) == before, "whole raw inverse: " + path)
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


def _configuration():
    return (PRODUCT_PARENT, PRODUCT_COMMIT, PRODUCT_PATHS, SOURCE_PATHS,
            copy.deepcopy(RAW_SHA256), copy.deepcopy(RAW_PATCHES), RECEIPT_PARENT,
            RECEIPT_COMMIT, copy.deepcopy(RECEIPT_RAW_SHA256), copy.deepcopy(RECEIPT_BATCH_SHA256),
            RECEIPT_SOURCE_MANIFEST_SHA256, ARC_PATHS, KO_PATH, RUNTIME_PATHS, INVENTORY_PATH,
            RATING_PATH, LEDGER_PATH, EVENT_IDS, ADDED_TEXT_LEAVES, LOCALES, RECEIPT_PATHS,
            PREDECESSOR_SOURCE_MANIFEST_SHA256, ROOT, __file__,
            _git, _objects, _snapshot, _disk_bytes, product_inverse, _arc_inverse,
            _validate_receipts, _receipt_semantics, _receipt_exports, receipt_overlay_inverse,
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
    _require(path in ARC_PATHS[2:] and (_sha(before), _sha(after)) == RECEIPT_RAW_SHA256.get(path),
             "target receipt raw pair")
    old, new = _Document(before), _Document(after)
    _require([r["id"] for r in old.value] == [r["id"] for r in new.value], "target event order/population")
    indices = {r["id"]: i for i, r in enumerate(old.value)}
    _require(len(indices) == len(old.value), "target duplicate event")
    expected, replacements = copy.deepcopy(old.value), []
    selected = set(selectors) - set(ADDED_TEXT_LEAVES)
    _require(len(selected) == 12, "exact twelve existing target corrections")
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
    _require(restored.encode("utf-8") == before, "target raw changed outside twelve exact JSON strings")
    return before


def _receipt_semantics(before, after, source_before):
    selectors = changed_text_selectors(source_before[KO_PATH], before[KO_PATH])
    _require(len(selectors) == 14 and set(ADDED_TEXT_LEAVES) <= set(selectors), "exact14 receipt selectors")
    _require(set(RECEIPT_RAW_SHA256) == set(RECEIPT_PATHS)
             and set(RECEIPT_BATCH_SHA256) == set(LOCALES), "receipt pin populations")
    for path in before:
        if path in RECEIPT_PATHS:
            _require((_sha(before[path]), _sha(after[path])) == RECEIPT_RAW_SHA256[path], "receipt raw " + path)
        else:
            _require(before[path] == after[path], "receipt changed a source/protected file")
    for path in ARC_PATHS[2:]:
        receipt_overlay_inverse(before[path], after[path], path, selectors)
    old, new = _loads(before[LEDGER_PATH]), _loads(after[LEDGER_PATH])
    expected = copy.deepcopy(old)
    ko = {row["id"]: row for row in _loads(after[KO_PATH])}
    ids = {"events:" + eid + ":/" + "/".join(map(str, keys)): (eid, keys) for eid, keys in selectors}
    new_ids = {"events:" + eid + ":/" + "/".join(map(str, keys)) for eid, keys in ADDED_TEXT_LEAVES}
    _require(new["batches"][:len(old["batches"])] == old["batches"]
             and len(new["batches"]) == len(old["batches"]) + 3, "exact old batch prefix plus three official imports")
    seen, revisions = set(), []
    for batch in new["batches"][len(old["batches"]):]:
        headers = batch.get("official_receipt_headers_by_locale", {})
        _require(type(headers) is dict and len(headers) == 1, "one official locale per batch")
        locale = next(iter(headers))
        _require(locale in LOCALES and locale not in seen and _digest(batch) == RECEIPT_BATCH_SHA256[locale],
                 "exact official receipt batch")
        seen.add(locale)
        path = "content/events_" + locale + "/arc_events.json"
        targets_before, targets_after = ({row["id"]: row for row in _loads(snapshot[path])}
                                         for snapshot in (before, after))
        rows, receipts = [], {}
        for identifier, (eid, keys) in sorted(ids.items()):
            source, target = _leaf(ko[eid], keys), _leaf(targets_after[eid], keys)
            source_hash = _digest({"path": KO_PATH, "field": keys, "ko": source})
            receipts[identifier] = {"source_sha256": source_hash, "target_sha256": _digest(target)}
            _require((identifier not in old["accepted"][locale]) == (identifier in new_ids),
                     "exact two first receipts and twelve corrections per locale")
            if identifier not in new_ids:
                _require(old["accepted"][locale][identifier] != receipts[identifier], "correction was already current")
            expected["accepted"][locale][identifier] = receipts[identifier]
            rows.append({"group": "events", "owner": eid, "source_path": KO_PATH, "path": list(keys),
                         "source": source, "category": "event_standard", "lifecycle": "shipping",
                         "protected": False, "runtime_support": "builtin_overlay_static_only",
                         "format_template": False, "id": identifier, "source_sha256": source_hash,
                         "locale": locale, "prompt_version": old["prompt_version"], "target_path": path,
                         "previous_target_sha256": _digest(_leaf(targets_before[eid], keys))})
        header = headers[locale]
        rebuilt = {"kind": "full_game_localization_batch", "schema_version": 1, "locale": locale,
                   "source_revision": header.get("source_revision"), "prompt_version": old["prompt_version"],
                   "source_manifest_sha256": RECEIPT_SOURCE_MANIFEST_SHA256,
                   "selection_sha256": _digest(rows), "count": 14, "source_language": "ko", "native_review": "OPEN"}
        rebuilt["batch_id"] = _digest(rebuilt)
        _require(header == rebuilt, "official export source/selection/old target binding")
        _require(batch.get("group") == "events" and batch.get("order") == "ORDER-470"
                 and batch.get("source_leaves") == 14 and batch.get("machine_validation") == "PASS"
                 and batch.get("native_review") == batch.get("rendered_review") == "OPEN",
                 "machine acceptance is not human approval")
        counts = batch.get("target_leaves_by_locale", {})
        _require(set(counts) <= set(LOCALES) and all(counts.get(loc, 0) == (14 if loc == locale else 0)
                                                   for loc in LOCALES), "receipt exact locale leaf census")
        receipt = {"batch": header, "state": "accepted_machine_validated", "native_review": "OPEN",
                   "translations": receipts}
        _require(batch.get("receipt_sha256_by_locale") == {locale: _digest(receipt)}, "actual official receipt digest")
        revisions.append(header["source_revision"])
    _require(seen == set(LOCALES), "complete official locale acceptance")
    expected["accepted_sha256"] = _digest(expected["accepted"])
    expected["batches"] = new["batches"]
    _require(_ordered(new) == _ordered(expected), "receipt successor exceeds exact6 first and36 corrected leaves")
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
    actual, _ = _snapshot(root, head, (*PRODUCT_PATHS, LEDGER_PATH))
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
            "current": actual, "receipts": receipts, "binding": _configuration()}


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
        comparison = {**hashes, **{p: _sha(proof["before"][p]) for p in SOURCE_PATHS}}
        _require(_digest(comparison) == PREDECESSOR_SOURCE_MANIFEST_SHA256,
                 "exact pre470 complete source census")
        actual, _ = _snapshot(root, proof["head"], tuple(hashes))
        _require({p: _sha(raw) for p, raw in actual.items()} == hashes
                 and all(_disk_bytes(Path(root) / p) == raw for p, raw in actual.items()),
                 "complete actual Git/disk source census")
        return {**inventory, "source_hashes": comparison, "source_manifest_sha256": _digest(comparison)}
