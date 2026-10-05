# 문장 개선 전체 목록 (2026-09-30 Claude 생성)

> 기준서는 [`PROSE_REVISION_MASTER_PLAN.md`](PROSE_REVISION_MASTER_PLAN.md)다. 이 목록은 작업 범위와 순서만
> 소유한다. 표시는 **후보 신호**이며 판정이 아니다. 표본 검증 정밀도는 약 50%이므로,
> 각 장면을 읽고 기준서로 판정한다. 표시가 없는 장면도 배치 안에서 함께 읽는다.

제품 사건 1708개(author_only 제외). 월 추정은 story_map·스케줄 코드·min_turn·
follow-up 상속으로 붙였고, `?`는 추정 실패(무작위 풀·조건부 사건)다.

| 신호 | 뜻 |
|---|---|
| P1 | 끝 문장이 추상 명사+상태 동사(해설·규칙 확인)로 닫힘 |
| P2 | 선택 직전 산문이 선택지를 요약·예고 |
| P4 | 조건 변형 본문이 원문보다 40% 넘게 짧음(원문 핵심 비트 손실 의심) |
| CV | 계약어(실제로·확정·사실로·빈칸·기록·시각) 1만 자당 40회 초과 |
| TENSE | KO 한 텍스트 안 현재형·과거형 서술 혼용 |
| LESSON | 결과문 마지막 세 문장 안에 격언·교훈형 문장 |
| THIN | (A층만) 결과문 평균 90자 미만 |
| EN_PRESENT | EN 서술이 현재형 위주(과거형 기본 규칙 전환 대상) |

## A층 — 정점(T1 추정: 레지스트리·전용 CG)

전체 50개, 신호 16개.

| 월 | 사건 | 파일 | 신호 |
|---:|---|---|---|
| 1 | `arc_intro_01_meal` | `arc_events.json` | EN_PRESENT |
| 2 | `kx_seollal_sebae` | `korea_holidays.json` | THIN |
| 3 | `arc_daeun_01_meet` | `arc_daeun.json` | EN_PRESENT |
| 3 | `arc_jiyeon_01_crash` | `arc_events.json` | EN_PRESENT |
| 4 | `arc_father_01_call` | `arc_events.json` | THIN |
| 26 | `arc_jiyeon_father_records` | `arc_web_crossbeams.json` | TENSE |
| 27 | `arc_jaehyuk_03_pitch` | `arc_events.json` | — |
| 30 | `arc_daeun_first_night` | `arc_daeun_romance.json` | — |
| 38 | `arc_daeun_proposal` | `arc_daeun_romance.json` | — |
| 38 | `arc_daeun_proposal_answer` | `arc_daeun_romance.json` | — |
| 38 | `arc_daeun_proposal_last_cup` | `arc_daeun_romance.json` | THIN |
| 44 | `arc_daeun_wedding_prep` | `arc_daeun_married.json` | — |
| 49 | `arc_y4_marriage_talk` | `arc_h2_beats.json` | — |
| 51 | `arc_daeun_wedding_aisle` | `arc_daeun_married.json` | — |
| 51 | `arc_daeun_wedding_day` | `arc_daeun_married.json` | — |
| 51 | `arc_daeun_wedding_groom_side` | `arc_daeun_married.json` | — |
| 51 | `arc_daeun_wedding_walk` | `arc_daeun_married.json` | — |
| 52 | `arc_jiyeon_wedding_gap` | `arc_jiyeon_married.json` | — |
| 52 | `arc_jiyeon_wedding_gap_decision` | `arc_jiyeon_married.json` | — |
| 52 | `arc_jiyeon_wedding_guest_list` | `arc_jiyeon_married.json` | — |
| 55 | `arc_y5_three_in_room` | `arc_pre_ending.json` | LESSON |
| 55 | `arc_y5_three_in_room_decision` | `arc_pre_ending.json` | — |
| 58 | `arc_daeun_final_choice` | `arc_daeun_married.json` | THIN |
| 58 | `arc_jiyeon_verdict` | `arc_jiyeon_married.json` | P1·THIN |
| ? | `arc_daeun_first_kiss` | `arc_date_milestones.json` | — |
| ? | `arc_daeun_first_kiss_choice` | `arc_date_milestones.json` | LESSON |
| ? | `arc_daeun_hometown_2` | `arc_romance_specials.json` | — |
| ? | `arc_daeun_hometown_table_decision` | `arc_romance_specials.json` | — |
| ? | `arc_daeun_wedding_groom_side_father_passed` | `arc_daeun_married.json` | — |
| ? | `arc_daeun_wedding_night` | `arc_romance_specials.json` | — |
| ? | `arc_date_namsan_lock_daeun` | `arc_date_milestones.json` | — |
| ? | `arc_date_namsan_lock_jiyeon` | `arc_date_milestones.json` | — |
| ? | `arc_date_park_daeun` | `arc_date_milestones.json` | — |
| ? | `arc_jiyeon_first_kiss` | `arc_date_milestones.json` | — |
| ? | `arc_jiyeon_first_kiss_choice` | `arc_date_milestones.json` | P1 |
| ? | `arc_jiyeon_narrow_room_2` | `arc_romance_specials.json` | — |
| ? | `arc_jiyeon_narrow_room_decision` | `arc_romance_specials.json` | — |
| ? | `arc_jiyeon_narrow_room_silence` | `arc_romance_specials.json` | THIN |
| ? | `arc_jiyeon_narrow_room_truth` | `arc_romance_specials.json` | — |
| ? | `arc_jiyeon_wedding_gap_father_passed` | `arc_jiyeon_married.json` | — |
| ? | `arc_jiyeon_wedding_guest_list_father_passed` | `arc_jiyeon_married.json` | — |
| ? | `arc_jiyeon_wedding_night` | `arc_romance_specials.json` | — |
| ? | `arc_season_cherry_daeun` | `arc_season_dates.json` | P1·THIN |
| ? | `arc_season_cherry_jiyeon` | `arc_season_dates.json` | THIN |
| ? | `arc_season_fireworks_daeun_decision` | `arc_season_dates.json` | P1 |
| ? | `arc_season_fireworks_jiyeon_decision` | `arc_season_dates.json` | — |
| ? | `arc_season_sea_daeun_decision` | `arc_season_dates.json` | — |
| ? | `arc_season_sea_jiyeon_decision` | `arc_season_dates.json` | — |
| ? | `arc_season_snow_daeun` | `arc_season_dates.json` | — |
| ? | `arc_season_snow_jiyeon` | `arc_season_dates.json` | — |

## B층 — 이야기 장면(arc·story_map)

전체 356개, 신호 148개.

| 월 | 사건 | 파일 | 신호 |
|---:|---|---|---|
| 2 | `arc_intro_03_sns` | `arc_events.json` | EN_PRESENT |
| 2 | `arc_temptation_clean` | `arc_events.json` | P1 |
| 3 | `arc_ch1_career_first_spec` | `arc_events.json` | P1 |
| 3 | `arc_ch1_invest_first_chart` | `arc_events.json` | LESSON |
| 3 | `arc_ch1_startup_first_idea` | `arc_events.json` | P1 |
| 3 | `arc_ch1_theme_network_first` | `arc_events.json` | LESSON |
| 3 | `arc_gosiwon_wall` | `arc_events.json` | LESSON |
| 3 | `arc_intro_04_hyunsu` | `arc_events.json` | EN_PRESENT |
| 3 | `arc_temptation_fallout` | `arc_events.json` | P1·CV |
| 4 | `arc_first_real_win_father_passed` | `arc_midgame.json` | LESSON |
| 4 | `arc_sangchul_01_answer` | `arc_events.json` | EN_PRESENT |
| 4 | `arc_sangchul_01_coffee` | `arc_events.json` | P1·EN_PRESENT |
| 4 | `arc_sangchul_01_measure` | `arc_events.json` | EN_PRESENT·LESSON |
| 4 | `arc_sangchul_01_meet` | `arc_events.json` | EN_PRESENT |
| 5 | `v2_jaehyuk_plain_reunion_echo` | `core_loop_v2_events.json` | EN_PRESENT |
| 6 | `arc_father_02_signal` | `arc_events.json` | TENSE |
| 6 | `arc_gangnam_visit_alone` | `arc_midgame.json` | EN_PRESENT |
| 6 | `arc_money_loneliness` | `arc_midgame.json` | P1 |
| 6 | `arc_money_loneliness_father_passed` | `arc_midgame.json` | P1 |
| 6 | `v2_demo_first_bill_opening` | `core_loop_v2_events.json` | CV·EN_PRESENT |
| 7 | `arc_spec_quant_result` | `arc_specialization.json` | LESSON |
| 8 | `arc_goshiwon_goodbye` | `arc_midgame.json` | P1 |
| 8 | `arc_sangchul_02_coffee` | `arc_events.json` | P4 |
| 9 | `arc_daeun_02b_dream` | `arc_daeun.json` | P1 |
| 9 | `arc_jiyeon_02_store` | `arc_events.json` | EN_PRESENT |
| 10 | `arc_y1_new_room_first_month` | `arc_midgame.json` | LESSON |
| 12 | `arc_year1_close` | `arc_year_close.json` | P4 |
| 13 | `arc_gangnam_real_estate_father_passed` | `arc_midgame.json` | P1 |
| 13 | `arc_year_one_mark` | `arc_midgame.json` | CV·EN_PRESENT |
| 14 | `arc_sangchul_03_network` | `arc_events.json` | P4 |
| 15 | `arc_father_medication` | `arc_midgame.json` | P1·EN_PRESENT |
| 16 | `arc_34_routine_trap` | `arc_midgame.json` | P1·CV·EN_PRESENT·LESSON |
| 17 | `arc_sangchul_human` | `arc_midgame.json` | P1·EN_PRESENT |
| 18 | `arc_jaehyuk_02_bond` | `arc_events.json` | TENSE |
| 18 | `arc_year_one_half` | `arc_midgame.json` | P1·TENSE·CV·EN_PRESENT·LESSON |
| 20 | `arc_34_doors_open` | `arc_chapter_themes.json` | P1 |
| 20 | `arc_sangchul_casino_decision` | `arc_events.json` | P1 |
| 20 | `arc_y2_worn_face` | `arc_h2_beats.json` | LESSON |
| 21 | `arc_opp_sangchul_realty` | `arc_events.json` | EN_PRESENT |
| 22 | `arc_daeun_03_fork` | `arc_daeun.json` | P2 |
| 22 | `arc_daeun_03_fork_hold_receipt` | `arc_daeun.json` | P1 |
| 22 | `arc_y2_relationship_fork_unattached` | `arc_midgame.json` | EN_PRESENT |
| 23 | `arc_34_parents_visit` | `arc_midgame.json` | EN_PRESENT |
| 24 | `arc_sangchul_mirror_receipt` | `arc_drama.json` | P1·LESSON |
| 24 | `arc_year2_close` | `arc_year_close.json` | P1·P4·CV |
| 25 | `arc_father_quiet_call` | `arc_midgame.json` | EN_PRESENT |
| 25 | `arc_y3_father_avoidance_document` | `arc_events.json` | P1·CV |
| 28 | `arc_y3_father_deferred_call` | `arc_midgame.json` | P1·CV |
| 28 | `arc_y3_jiyeon_departure` | `arc_year3_drama.json` | P1 |
| 29 | `arc_jaehyuk_wait` | `arc_midgame.json` | EN_PRESENT |
| 29 | `arc_why_gangnam_real` | `arc_drama.json` | P1 |
| 30 | `arc_jaehyuk_ghost_message` | `arc_events.json` | P1 |
| 31 | `arc_sangchul_known_reflex` | `arc_midgame.json` | LESSON |
| 32 | `arc_father_06_confession` | `arc_drama.json` | EN_PRESENT |
| 33 | `arc_sangchul_confrontation` | `arc_drama.json` | P4 |
| 33 | `arc_y3_sangchul_deeper_room` | `arc_h2_beats.json` | P4 |
| 34 | `arc_y3_cost_of_knowing` | `arc_year3_drama.json` | P1 |
| 35 | `arc_minjun_first_call` | `arc_year3_drama.json` | LESSON |
| 37 | `arc_1b_isolation` | `arc_drama.json` | P1 |
| 37 | `arc_daeun_year4_together` | `arc_daeun_extension.json` | LESSON |
| 38 | `arc_36_trust_crack` | `arc_chapter_themes.json` | LESSON |
| 38 | `arc_jiyeon_narrow_room_1` | `arc_romance_specials.json` | P2 |
| 38 | `arc_year_three_crossroads` | `arc_midgame.json` | LESSON |
| 39 | `arc_36_father_comes_to_seoul` | `arc_drama.json` | P1 |
| 39 | `arc_y4_three_promises` | `arc_chapter_themes.json` | CV |
| 39 | `arc_y4_three_promises_deal_only` | `arc_chapter_themes.json` | P2·CV |
| 39 | `arc_y4_three_promises_jiyeon_and_deal` | `arc_chapter_themes.json` | P1·CV |
| 40 | `arc_36_unexpected_hand` | `arc_chapter_themes.json` | P2·P1·CV |
| 40 | `arc_36_unexpected_hand_father_deal` | `arc_chapter_themes.json` | CV |
| 40 | `arc_36_unexpected_hand_person_deal` | `arc_chapter_themes.json` | CV |
| 41 | `arc_36_body_signal` | `arc_midgame.json` | P1·P4 |
| 41 | `arc_y4_body_witness_hyunsu` | `arc_chapter_themes.json` | CV·LESSON |
| 41 | `arc_y4_body_witness_jiyeon` | `arc_chapter_themes.json` | P1·CV |
| 42 | `arc_y4_family_commitment_none` | `arc_chapter_themes.json` | CV |
| 42 | `arc_y4_family_partner_collision` | `arc_chapter_themes.json` | P1 |
| 42 | `arc_y4_family_partner_collision_jiyeon` | `arc_chapter_themes.json` | CV |
| 42 | `arc_y4_family_table_missed` | `arc_chapter_themes.json` | P2·P1·CV |
| 43 | `arc_year_three_half` | `arc_midgame.json` | P1·P2·TENSE·P4·CV |
| 44 | `arc_father_call_on_ktx_number` | `arc_drama.json` | P1 |
| 44 | `arc_y4_father_call_answered_on_ktx` | `arc_drama.json` | P2·P1 |
| 44 | `arc_y4_father_call_missed_on_ktx` | `arc_drama.json` | P1·CV |
| 45 | `arc_y4_borrowed_name_document_gap` | `arc_chapter_themes.json` | P1·CV |
| 46 | `arc_36_night_doubt` | `arc_midgame.json` | P4 |
| 46 | `arc_y4_bill_night_jiyeon` | `arc_chapter_themes.json` | CV |
| 46 | `arc_y4_bill_night_unattached` | `arc_chapter_themes.json` | P2 |
| 47 | `arc_father_passing` | `arc_drama.json` | P1·P4·CV |
| 47 | `arc_father_passing_deal_morning` | `arc_drama.json` | CV |
| 47 | `arc_father_passing_platform` | `arc_drama.json` | CV |
| 47 | `arc_y4_father_crisis_contact` | `arc_drama.json` | P2·P1·CV |
| 47 | `arc_y4_father_crisis_stabilized` | `arc_drama.json` | CV·LESSON |
| 47 | `arc_y4_father_final_contact_called` | `arc_drama.json` | P2·P1 |
| 47 | `arc_y4_father_final_contact_missed` | `arc_drama.json` | P2·CV |
| 47 | `arc_y4_father_final_contact_present` | `arc_drama.json` | P1 |
| 47 | `arc_y4_father_outcome_unknown` | `arc_drama.json` | CV |
| 48 | `arc_y4_year_close_daeun` | `arc_year_close.json` | P1·CV·LESSON |
| 48 | `arc_y4_year_close_jiyeon` | `arc_year_close.json` | P1·CV |
| 48 | `arc_y4_year_close_unattached` | `arc_year_close.json` | P1·CV |
| 48 | `arc_year4_close` | `arc_year_close.json` | P1·P4·CV |
| 49 | `arc_daeun_y5_feelings` | `arc_romance_y5.json` | P1 |
| 49 | `arc_jiyeon_year5_news` | `arc_year3_drama.json` | P1 |
| 49 | `arc_y5_contract_cover_investment` | `arc_midgame.json` | LESSON |
| 49 | `arc_y5_contract_reviewer_delivery_sangchul` | `arc_midgame.json` | P2·TENSE |
| 50 | `arc_y5_final_push_deadline_investment` | `arc_midgame.json` | P1·CV |
| 50 | `arc_y5_protection_boundary_daeun` | `arc_midgame.json` | CV |
| 51 | `arc_y5_after_goal_daeun` | `arc_new_characters.json` | P1 |
| 51 | `arc_y5_burnout_check_reference` | `arc_new_characters.json` | CV |
| 51 | `arc_y5_minseo_goal_cost_reference` | `arc_new_characters.json` | P2·CV |
| 52 | `arc_37_burn_or_light` | `arc_midgame.json` | LESSON |
| 52 | `arc_late_game_push` | `arc_midgame.json` | P1·CV |
| 53 | `arc_jaehyuk_mirror_decision` | `arc_drama.json` | LESSON |
| 53 | `arc_y5_general_name_boundary_exact` | `arc_pre_ending.json` | LESSON |
| 53 | `arc_y5_guarantee_protected_show_daeun` | `arc_drama.json` | TENSE·P1·CV |
| 53 | `arc_y5_jaehyuk_guarantee_decision_reference` | `arc_drama.json` | TENSE·CV |
| 53 | `arc_y5_jaehyuk_return_call_reference` | `arc_drama.json` | P2 |
| 54 | `arc_y5_sangchul_review_receipt` | `arc_pre_ending.json` | P1 |
| 55 | `arc_y5_general_debt_memory_reconnect` | `arc_pre_ending.json` | P1·CV |
| 56 | `arc_37_ending_peace` | `arc_midgame.json` | P4 |
| 56 | `arc_y5_father_trace_alive_exact` | `arc_year3_drama.json` | CV |
| 56 | `arc_y5_father_trace_custody` | `arc_year3_drama.json` | CV |
| 56 | `arc_y5_father_trace_passed_exact` | `arc_year3_drama.json` | P1·CV |
| 57 | `arc_y5_name_on_line_daeun_routed` | `arc_pre_ending.json` | CV |
| 58 | `arc_daeun_final_choice_decision` | `arc_daeun_married.json` | P2 |
| 58 | `arc_daeun_final_choice_kitchen` | `arc_daeun_married.json` | P1 |
| 58 | `arc_y5_general_debt_memory_cafe_exact` | `arc_pre_ending.json` | CV |
| 58 | `arc_y5_general_debt_memory_voice_exact` | `arc_pre_ending.json` | CV |
| 58 | `arc_y5_people_verdict_daeun_exact` | `arc_pre_ending.json` | P1 |
| 59 | `arc_y5_property_not_executed_notice` | `arc_pre_ending.json` | CV |
| 60 | `arc_final_countdown_general_near_goal_passed` | `arc_pre_ending.json` | CV |
| 60 | `arc_final_week` | `arc_drama.json` | P1·P4 |
| 60 | `arc_y5_final_father_answer_alive` | `arc_year3_drama.json` | CV |
| 60 | `arc_y5_final_father_answer_passed` | `arc_year3_drama.json` | CV |
| 60 | `arc_y5_final_week_daeun_outbound` | `arc_drama.json` | CV |
| 60 | `arc_y5_final_week_general_people_outbound` | `arc_drama.json` | CV |
| 60 | `arc_y5_general_final_record_seal` | `arc_pre_ending.json` | TENSE·P1 |
| 60 | `arc_y5_remaining_jaehyuk_or_self` | `arc_drama.json` | P1·CV |
| ? | `arc_housing_keepsake` | `arc_housing_keepsake.json` | CV |
| ? | `arc_jiyeon_year4_seoul` | `arc_year3_drama.json` | P1 |
| ? | `arc_money_check_high` | `arc_events.json` | P1 |
| ? | `arc_money_check_mid` | `arc_events.json` | P1 |
| ? | `arc_opp_sangchul_lose` | `arc_events.json` | P1 |
| ? | `arc_season_sea_jiyeon` | `arc_season_dates.json` | LESSON |
| ? | `arc_spec_found` | `arc_specialization.json` | LESSON |
| ? | `arc_why_gangnam_real_father_passed` | `arc_drama.json` | P1 |
| ? | `arc_year1_close_father_passed` | `arc_year_close.json` | P4 |
| ? | `arc_year2_scene` | `arc_year_close.json` | P2 |
| ? | `arc_year4_close_father_passed` | `arc_year_close.json` | P1·P4·CV |
| ? | `arc_year4_scene` | `arc_year_close.json` | P2 |
| ? | `arc_year5_scene` | `arc_year_close.json` | P2 |

## C층 — 여파 장면(callback)

전체 626개, 신호 106개.

C층은 탐지에 기대지 않고 **파일 단위로 전부** 읽는다. 표의 LESSON 수는 우선순위 참고용이다.

| 배치 | 파일 | 사건 수 | LESSON 신호 | 신호 사건 |
|---|---|---:|---:|---|
| C01 | `callback_events_48.json` | 14 | 6 | `callback_bought_first_luxury_echo`(LESSON), `callback_did_staycation_echo`(LESSON), `callback_resisted_luxury_echo`(LESSON), `callback_sns_detoxed_echo`(LESSON), `callback_talked_about_bihon_echo`(LESSON), `callback_yolo_regretted_echo`(LESSON) |
| C02 | `callback_events_47.json` | 13 | 5 | `callback_admitted_fear_echo`(LESSON), `callback_almost_messaged_daeun_echo`(EN_PRESENT), `callback_demo_resolved_echo`(LESSON), `callback_double_down_10b_echo`(LESSON), `callback_relaxed_at_night_echo`(LESSON), `callback_ten_b_anxiety_echo`(LESSON) |
| C03 | `callback_events_54.json` | 13 | 5 | `callback_contacted_jaehyuk_early_echo`(LESSON), `callback_holdem_mentor_met_echo`(LESSON), `callback_impressed_jiyeon_mother_echo`(LESSON), `callback_overtime_boundary_echo`(LESSON), `callback_sought_help_echo`(LESSON) |
| C04 | `callback_events_11.json` | 17 | 5 | `callback_health_treated_followup`(LESSON), `callback_junk_sale_connection_echo`(LESSON), `callback_redev_bet_failed_result`(P1), `callback_redev_bet_taken_result`(LESSON), `callback_salary_negotiation_outcome`(LESSON), `callback_visited_gangnam_open_house_echo`(LESSON) |
| C05 | `callback_events_52.json` | 14 | 4 | `callback_cafe_redeemed_echo`(LESSON), `callback_cafe_still_ashamed_echo`(LESSON), `callback_considered_job_change_echo`(LESSON), `callback_daeun_reason_confirmed_echo`(LESSON), `callback_ignored_hyunsu_warning_echo`(EN_PRESENT) |
| C06 | `callback_events_44.json` | 14 | 4 | `callback_birthday_rest_echo`(LESSON), `callback_cut_sns_echo`(LESSON), `callback_hid_room_parents_echo`(LESSON), `callback_ignored_body_echo`(EN_PRESENT), `callback_missed_gosiwon_echo`(LESSON) |
| C07 | `callback_events_53.json` | 13 | 3 | `callback_enrolled_english_echo`(LESSON), `callback_jeongseon_quit_vow_echo`(LESSON), `callback_jeongseon_self_aware_echo`(LESSON), `callback_success_undefined_echo`(EN_PRESENT) |
| C08 | `callback_events_7.json` | 12 | 3 | `callback_elite_recognized_weight`(LESSON), `callback_jaehyuk_stood_up_aftermath`(LESSON), `callback_jiyeon_had_coffee_echo`(LESSON) |
| C09 | `callback_events_6.json` | 18 | 3 | `callback_credit_backed_down_consequence`(LESSON), `callback_daeun_guarded_distance`(LESSON), `callback_father_going_soon_visit`(P1), `callback_father_reconciled_started_progress`(LESSON) |
| C10 | `callback_events_45.json` | 14 | 2 | `callback_doubted_job_echo`(LESSON), `callback_reconsidering_job_echo`(LESSON) |
| C11 | `callback_events_13.json` | 15 | 2 | `callback_delayed_visiting_dad_consequence`(LESSON), `callback_jeonse_insurance_saved_echo`(LESSON) |
| C12 | `callback_events_46.json` | 13 | 2 | `callback_avoided_comparison_echo`(LESSON), `callback_quit_abruptly_echo`(LESSON) |
| C13 | `callback_events_49.json` | 14 | 2 | `callback_committed_to_course_echo`(LESSON), `callback_followed_leading_room_echo`(LESSON) |
| C14 | `callback_events_27.json` | 7 | 2 | `callback_budget_check_in`(LESSON), `callback_mid_goal_echo`(LESSON), `callback_stayed_grounded_echo`(EN_PRESENT) |
| C15 | `callback_events_8.json` | 16 | 2 | `callback_cafe_honest_patient_payoff`(LESSON), `callback_cafe_stole_walked_echo`(LESSON) |
| C16 | `callback_events_24.json` | 14 | 2 | `callback_cafe_stole_lead_echo`(LESSON), `callback_daeun_committed_echo`(LESSON), `callback_spec_elite_echo`(P1) |
| C17 | `callback_events_43.json` | 14 | 2 | `callback_goal_questioned_echo`(LESSON), `callback_solo_celebration_echo`(LESSON), `callback_told_daeun_everything_echo`(P1) |
| C18 | `callback_events_50.json` | 14 | 2 | `callback_casino_accepted_comp_echo`(EN_PRESENT), `callback_casino_declined_comp_echo`(CV·LESSON), `callback_confessed_coworker_echo`(LESSON) |
| C19 | `callback_events_10.json` | 17 | 2 | `callback_confronted_jiyeon_respect`(P1·LESSON), `callback_has_certification_applied`(LESSON), `callback_headhunted_choice`(P1), `callback_rushed_to_father_moment_father_passed`(CV) |
| C20 | `callback_events_12.json` | 15 | 2 | `callback_jiyeon_acknowledged_echo`(LESSON), `callback_jiyeon_forgave_complexity_echo`(LESSON) |
| C21 | `callback_events_9.json` | 15 | 2 | `callback_leverage_addict_margin_call`(LESSON), `callback_questioned_orthodox_answer`(LESSON) |
| C22 | `callback_events_5.json` | 19 | 1 | `callback_shadow_investors_proposal`(LESSON) |
| C23 | `callback_events_51.json` | 13 | 1 | `callback_first_invest_win_echo`(LESSON) |
| C24 | `callback_events_14.json` | 15 | 1 | `callback_stayed_clean_echo`(LESSON) |
| C25 | `callback_events_3.json` | 16 | 1 | `callback_cafe_honest_win_deeper`(LESSON) |
| C26 | `callback_events_16.json` | 14 | 1 | `callback_greed_learned_echo`(LESSON) |
| C27 | `callback_events_55.json` | 5 | 1 | `callback_gangnam_reason_father_echo`(LESSON) |
| C28 | `callback_events_20.json` | 15 | 1 | `callback_jobswitch_declined_echo`(LESSON) |
| C29 | `callback_events_17.json` | 14 | 1 | `callback_parent_bond_deepened_echo`(LESSON) |
| C30 | `callback_events_21.json` | 15 | 1 | `callback_coin_refused_echo`(LESSON), `callback_holdem_big_win_echo`(P1) |
| C31 | `callback_events_22.json` | 15 | 1 | `callback_fomo_invested_echo`(LESSON) |
| C32 | `callback_events_23.json` | 14 | 1 | `callback_escaped_dirty_money_echo`(P1), `callback_spec_quant_echo`(LESSON) |
| C33 | `callback_events_35.json` | 5 | 1 | `callback_truth_echo`(EN_PRESENT·LESSON) |
| C34 | `callback_events_40.json` | 6 | 1 | `callback_midpoint_steady_echo`(EN_PRESENT), `callback_sangchul_personal_echo`(LESSON) |
| C35 | `callback_events.json` | 12 | 1 | `callback_father_promise`(LESSON), `callback_gambling_memory`(TENSE·EN_PRESENT) |
| C36 | `callback_events_30.json` | 3 | 1 | `callback_gangnam_standard_held`(EN_PRESENT), `callback_vision_midcheck`(LESSON) |
| C37 | `callback_events_34.json` | 7 | 1 | `callback_jeonse_protected_safe`(P1), `callback_overtime_burnout`(EN_PRESENT), `callback_recycling_neighbor`(LESSON) |
| C38 | `callback_events_4.json` | 18 | 0 |  |
| C39 | `arc_date_milestones.json` | 2 | 0 |  |
| C40 | `callback_events_36.json` | 4 | 0 | `callback_asked_father_more_echo`(P1), `callback_medication_ignored_echo`(P1), `callback_medication_visited_echo`(P1) |
| C41 | `callback_events_25.json` | 15 | 0 | `callback_political_winner_echo`(P1) |
| C42 | `callback_events_29.json` | 4 | 0 |  |
| C43 | `callback_events_42.json` | 6 | 0 | `callback_chose_money_father_echo`(EN_PRESENT) |
| C44 | `callback_events_18.json` | 15 | 0 |  |
| C45 | `callback_events_2.json` | 21 | 0 | `callback_startup_grind_result`(EN_PRESENT) |
| C46 | `callback_events_31.json` | 3 | 0 |  |
| C47 | `callback_events_15.json` | 11 | 0 |  |
| C48 | `callback_events_37.json` | 6 | 0 | `callback_knows_dad_reason_echo`(P1) |
| C49 | `callback_events_39.json` | 6 | 0 | `callback_daeun_married_echo`(EN_PRESENT) |
| C50 | `callback_events_19.json` | 15 | 0 | `callback_deleted_sns_echo`(P1) |
| C51 | `callback_events_32.json` | 4 | 0 |  |
| C52 | `callback_events_41.json` | 4 | 0 |  |
| C53 | `callback_events_38.json` | 2 | 0 |  |
| C54 | `callback_events_26.json` | 4 | 0 |  |
| C55 | `callback_events_33.json` | 2 | 0 |  |

## E층 — 일반·무작위 사건

전체 676개, 신호 120개.

E층은 신호 사건만 싣는다. 무작위 풀이라 노출 빈도가 높은 것부터 본다(가중치 내림차순).

| 사건 | 파일 | 가중치 | 신호 |
|---|---|---:|---|
| `sangchul_meet` | `life_events.json` | 10.0 | LESSON |
| `hidden_008` | `hidden_events.json` | 8 | LESSON |
| `inv_redev_zone_tip` | `investment_events.json` | 8 | P1·CV |
| `egg_veteran_return` | `easter_eggs.json` | 5 | TENSE |
| `sangchul_last_lesson` | `relationship_events.json` | 5.0 | P1 |
| `hidden_chaebol_elevator` | `hidden_events.json` | 4 | EN_PRESENT |
| `gambling_020` | `investment_events.json` | 4 | EN_PRESENT |
| `inv_hot_tip_kakao` | `investment_events.json` | 4.0 | EN_PRESENT |
| `inv_dca_commitment` | `investment_events.json` | 4.0 | LESSON |
| `health_008` | `life_events.json` | 4 | LESSON |
| `family_005` | `relationship_events.json` | 4 | EN_PRESENT·LESSON |
| `inv_recession_news` | `investment_events.json` | 3.5 | LESSON |
| `story_weekend_choice` | `story_events.json` | 3.5 | P1 |
| `hidden_screen_time` | `hidden_events.json` | 3.0 | LESSON |
| `inv_loss_cut_decision` | `investment_events.json` | 3.0 | LESSON |
| `inv_stock_ipo_lottery` | `investment_events.json` | 3.0 | EN_PRESENT |
| `inv_real_estate_bubble_fear` | `investment_events.json` | 3.0 | EN_PRESENT |
| `inv_portfolio_review` | `investment_events.json` | 3.0 | EN_PRESENT |
| `inv_ipo_hot_tip` | `investment_events.json` | 3 | EN_PRESENT |
| `orthodox_integrity_reward` | `investment_events.json` | 2.5 | EN_PRESENT |
| `unorthodox_gray_zone_tip` | `investment_events.json` | 2.5 | EN_PRESENT |
| `rel_online_community_tribe` | `relationship_events.json` | 2.5 | EN_PRESENT |
| `story_hometown_nostalgia` | `story_events.json` | 2.5 | P1 |
| `inv_market_crash_alert` | `investment_events.json` | 2.0 | P1 |
| `jeonse_scam_warning` | `life_events.json` | 2.0 | LESSON |
| `creator_breakout_video` | `drama_events.json` | 1.8 | LESSON |
| `gambling_002` | `investment_events.json` | 1.7 | EN_PRESENT |
| `politics_025` | `investment_events.json` | 1.7 | EN_PRESENT |
| `amb_credit_steal_00` | `amb_scenarios6.json` | 1.4 | TENSE |
| `season_rainy_commute` | `life_events.json` | 1.4 | EN_PRESENT |
| `yolo_spend_moment` | `social_independence.json` | 1.4 | EN_PRESENT |
| `work_lunch_alone` | `work_events.json` | 1.4 | LESSON |
| `kx_yageun` | `korea_workplace.json` | 1.3 | EN_PRESENT·LESSON |
| `work_credit_stolen` | `work_events.json` | 1.3 | LESSON |
| `amb_holiday_00` | `amb_scenarios2.json` | 1.2 | TENSE |
| `amb_health_00` | `amb_scenarios3.json` | 1.2 | TENSE |
| `drama_crypto_allin` | `drama_events.json` | 1.2 | EN_PRESENT |
| `kx_heatwave` | `korea_climate.json` | 1.2 | EN_PRESENT |
| `kx_cold_snap` | `korea_climate.json` | 1.2 | EN_PRESENT |
| `kx_claw_machine` | `korea_experience.json` | 1.2 | LESSON |
| `kx_parcel_locker` | `korea_survival.json` | 1.2 | EN_PRESENT |
| `survival_friend_sns` | `life_events.json` | 1.2 | LESSON |
| `bihon_friend_talk` | `social_independence.json` | 1.2 | LESSON |
| `work_burnout_monday` | `work_events.json` | 1.2 | EN_PRESENT·LESSON |
| `cb_grace_echo` | `callback_chapter_themes.json` | 1.1 | P1·CV |
| `kx_tax_refund` | `korea_admin.json` | 1.1 | LESSON |
| `kx_viral_meme` | `korea_digital.json` | 1.1 | EN_PRESENT |
| `kx_jumin_center` | `korea_survival.json` | 1.1 | EN_PRESENT |
| `kx_kkondae` | `korea_workplace.json` | 1.1 | EN_PRESENT |
| `chain_exec_meal` | `chain_events.json` | 1.0 | P2 |
| `drama_office_politics` | `drama_events.json` | 1.0 | EN_PRESENT |
| `friend_success_gap` | `friendship_events.json` | 1.0 | LESSON |
| `kx_gosi_study` | `korea_education.json` | 1.0 | EN_PRESENT |
| `kx_office_politics` | `korea_workplace.json` | 1.0 | LESSON |
| `shadow_loan_collector` | `shadow_events.json` | 1.0 | EN_PRESENT |
| `shadow_old_promise` | `shadow_events.json` | 1.0 | CV |
| `yolo_morning_after` | `social_independence.json` | 1.0 | LESSON |
| `solo_life_discovery` | `social_independence.json` | 1.0 | EN_PRESENT |
| `flex_golf_invite` | `social_independence.json` | 1.0 | LESSON |
| `gig_delivery_night` | `viral_events.json` | 1.0 | TENSE·LESSON |
| `identity_10year_vision` | `identity_events.json` | 0.9 | LESSON |
| `kx_suneung_day` | `korea_education.json` | 0.9 | EN_PRESENT |
| `selfdev_english_class` | `life_events.json` | 0.9 | EN_PRESENT |
| `leading_room_joined` | `viral_events.json` | 0.9 | TENSE·LESSON |
| `debt_invest_margin_call` | `viral_events.json` | 0.9 | LESSON |
| `kx_real_estate_jeonse` | `korea_admin.json` | 0.8 | EN_PRESENT·LESSON |
| `romance_blind_date` | `life_events.json` | 0.8 | EN_PRESENT |
| `creator_hater_crisis` | `drama_events.json` | 0.7 | EN_PRESENT |
| `casino_comp_offer` | `gambling_narrative.json` | 0.7 | CV·EN_PRESENT |
| `late_night_driver` | `life_events.json` | 0.7 | P1 |
| `rel_job_change_offer` | `relationship_events.json` | 0.55 | EN_PRESENT |
| `jobs_004` | `relationship_events.json` | 0.55 | EN_PRESENT |
| `drama_election_theme_stock` | `drama_events.json` | 0.4 | EN_PRESENT |
| `drama_parents_financial_crisis` | `drama_events.json` | 0.3 | LESSON |
| `butterfly_mystery_info_result_scam` | `butterfly_events.json` | 0.2 | LESSON |
| `amb_holiday_home` | `amb_scenarios2.json` | 0 | TENSE |
| `amb_mlm_meet` | `amb_scenarios3.json` | 0 | LESSON |
| `amb_mlm_aftermath_father_passed` | `amb_scenarios3.json` | 0 | P1·EN_PRESENT |
| `recovery_first_week` | `arc_addiction_recovery.json` | 0 | LESSON |
| `hidden_whole_picture` | `arc_drama.json` | 0 | TENSE |
| `hyunsu_reunion_meet` | `arc_hyunsu.json` | 0 | LESSON |
| `hyunsu_year5_call` | `arc_hyunsu.json` | 0 | P1 |
| `hyunsu_year5_call_father_passed` | `arc_hyunsu.json` | 0 | P1 |
| `v2_opening_application_send` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_opening_return_math` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_hyunsu_study_followup` | `core_loop_v2_events.json` | 0 | P1·EN_PRESENT |
| `v2_hanbit_interview` | `core_loop_v2_events.json` | 0 | CV·EN_PRESENT |
| `v2_daeun_return_named` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_sangchul_housing_lead` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_daeun_third_greeting` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_jiyeon_second_crossing` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_sangchul_demo_echo` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_father_health_signal` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_dirty_trace_initial_call` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_dirty_recruiter_week24` | `core_loop_v2_events.json` | 0 | P1 |
| `v2_gangnam_receipt_walk` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_empty_sunday` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_demo_first_bill` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_m3_room_ledger_anchor` | `core_loop_v2_events.json` | 0 | EN_PRESENT |
| `v2_m4_housing_consultation_anchor` | `core_loop_v2_events.json` | 0 | P1·EN_PRESENT |
| `ng_recovery_mentor_moment` | `ng_plus_events.json` | 0 | LESSON |
| `rel_family_visit_seoul_father_passed` | `relationship_events.json` | 0 | P1 |
| `cafe_00` | `scenario_cafe.json` | 0 | CV |
| `cafe_listen_01` | `scenario_cafe.json` | 0 | EN_PRESENT |
| `cafe_bluff_caught` | `scenario_cafe.json` | 0 | P2 |
| `shadow_snitch_found` | `shadow_events.json` | 0.0 | EN_PRESENT |
| `shadow_promise_again` | `shadow_events.json` | 0.0 | CV |
| `story_flashforward` | `story_events.json` | 0 | EN_PRESENT |
| `story_knee_witness` | `story_events.json` | 0 | EN_PRESENT |
| `story_knee_choice` | `story_events.json` | 0 | EN_PRESENT |
| `story_last_payment_word` | `story_events.json` | 0 | EN_PRESENT |
| `story_prologue_dad` | `story_events.json` | 0 | EN_PRESENT |
| `story_prologue_goal` | `story_events.json` | 0 | EN_PRESENT |
| `story_prologue_meal` | `story_events.json` | 0 | EN_PRESENT |
| `story_one_year` | `story_events.json` | 0 | EN_PRESENT |
| `story_first_savings_milestone` | `story_events.json` | 0 | LESSON |
| `story_one_half_year` | `story_events.json` | 0 | EN_PRESENT |
| `age_35_checkpoint` | `story_events.json` | 0 | EN_PRESENT |
| `age_39_final` | `story_events.json` | 0 | EN_PRESENT |
| `story_hometown_nostalgia_father_passed` | `story_events.json` | 0 | P1 |
