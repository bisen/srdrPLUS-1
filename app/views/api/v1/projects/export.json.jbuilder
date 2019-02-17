json.project do
  json.id @project.id
  json.name @project.name
  json.description @project.description
  json.attribution @project.attribution
  json.methodology_description @project.methodology_description
  json.prospero @project.prospero
  json.doi @project.doi
  json.notes @project.notes
  json.funding_source @project.funding_source

  json.users do
    @project.projects_users.each do |pu|
      json.set! pu.user.id do
        json.email pu.user.email
        json.profile do
          json.username pu.user.profile.username
          json.first_name pu.user.profile.first_name
          json.middle_name pu.user.profile.middle_name
          json.last_name pu.user.profile.last_name
          json.time_zone pu.user.profile.time_zone
          json.organization do
            json.id pu.user.profile.organization.id
            json.name pu.user.profile.organization.name
          end
        end
        json.roles do
          pu.roles.each do |r|
            json.set! r.id do
              json.name r.name
            end
          end
        end

        json.term_groups do
          pu.projects_users_term_groups_colors.each do |putgc|
            json.set! putgc.term_group.id do
              json.color do
                json.id putgc.color.id
                json.name putgc.color.name
                json.hex_code putgc.color.hex_code
              end
              json.name putgc.term_group.name
              json.set! :terms do
                putgc.terms.each do |term|
                  json.set! term.id do
                    json.name term.name
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  json.key_questions do
    @project.key_questions_projects.each do |kqp|
      json.set! kqp.key_question.id do
        json.name kqp.key_question.name
        #json.position kqp.ordering.position  ####### need to make sure kqp has ordering and position -Birol
      end
    end
  end

  json.citations do
    @project.citations_projects.each do |cp|
      json.set! cp.citation.id do
        json.name cp.citation.name
        json.abstract cp.citation.abstract
        json.refman cp.citation.refman
        json.pmid cp.citation.pmid
        json.journal do
          json.id cp.citation.journal.id
          json.name cp.citation.journal.name
        end
        json.keywords do
          cp.citation.keywords.each do |kw|
            json.set! kw.id do
              json.name kw.name
            end
          end
        end
        json.authors do
          cp.citation.authors.each do |a|
            json.set! a.id do
              json.name a.name
            end
          end
        end
        json.labels do
          cp.labels.each do |ll|
            json.set! ll.id do
              json.labeler_user_id ll.projects_users_role.user.id
              json.labeler_role_id ll.projects_users_role.role.id
              json.label_type do
                json.id ll.label_type.id
                json.name ll.label_type.name
              end

              json.set! :reasons do
                ll.reasons.each do |r|
                  json.set! r.id do
                    json.name r.name
                  end
                end
              end
            end
          end
        end

        json.tags do
          cp.taggings.each do |tt|
            json.set! tt.tag.id do
              json.creator_user_id tt.projects_users_role.user.id
              json.creator_role_id tt.projects_users_role.role.id
              json.name tt.tag.name
            end
          end
        end

        json.notes do
          cp.notes.each do |n|
            json.set! n.id do
              json.creator_user_id n.projects_users_role.user.id
              json.creator_role_id n.projects_users_role.role.id
              json.value n.value
            end
          end
        end
      end
    end
  end

  json.tasks do
    @project.tasks.each do |tt|
      json.set! tt.id do
        json.task_type do
          json.id tt.task_type.id
          json.name tt.task_type.name
        end
        json.num_assigned tt.num_assigned
        json.set! :assignments do
          tt.assignments.each do |a|
            json.set! a.id do
              json.assignee_user_id a.projects_users_role.user.id
              json.assignee_role_id a.projects_users_role.role.id
              json.done_so_far a.done_so_far
              json.date_due a.date_due
              json.done a.done
            end
          end
        end
      end
    end
  end

  json.extraction_forms do
    @project.extraction_forms_projects.each do |efp|
      json.set! efp.id do
        ef = efp.extraction_form

        json.sections do
          efp.extraction_forms_projects_sections.each do |efps|

            json.set! efps.id do
              json.name efps.section.name
              json.position efps.ordering.position

              json.extraction_forms_projects_section_type do
                json.id efps.extraction_forms_projects_section_type.id
                json.name efps.extraction_forms_projects_section_type.name
              end

              if efps.extraction_forms_projects_section_option.present?
                json.extraction_forms_projects_section_option do
                  json.id efps.extraction_forms_projects_section_option.id
                  json.by_type1 efps.extraction_forms_projects_section_option.by_type1
                  json.include_total efps.extraction_forms_projects_section_option.include_total
                end
              end

              json.type1s do
                efps.type1s.each do |t1|
                  json.set! t1.id do
                    json.name t1.name
                    json.description t1.description
                  end
                end
              end

              if efps.link_to_type1.present?
                json.linked_type1 efps.link_to_type1.id
              end

              json.questions do
                efps.questions.each do |q|
                  json.set! q.id do
                    json.name q.name
                    json.description q.description
                    json.position q.ordering.position
                    json.key_questions do
                      jq.key_questions_projects.each do |kqp|
                        json.set! kqp.key_question.id do
                          json.name kqp.key_question.name
                        end
                      end
                    end
                    json.question_rows do
                      q.question_rows.each do |qr|
                        json.set! qr.id do
                          json.name qr.name
                          json.question_row_columns do
                            qr.question_row_columns.each do |qrc|
                              json.set! qrc.id do
                                json.name qrc.name
                                json.question_row_column_type do
                                  json.id qrc.question_row_column_type.id
                                  json.name qrc.question_row_column_type.name
                                end
                                json.question_row_column_options do
                                  qrc.question_row_column_options.each do |qrco|
                                    json.set! qrco.id do
                                      json.name qrco.name
                                    end
                                  end
                                end
                                json.question_row_column_fields do
                                  qrc.question_row_column_fields.each do |qrcf|
                                    json.set! qrcf.id do
                                      json.name qrcf.name
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  json.extractions do
    @project.extractions.each do |ex|
      json.set! ex.id do
        json.citation_id ex.citations_project.citation.id
        json.extractor_user_id ex.projects_users_role.user.id
        json.extractor_role_id ex.projects_users_role.role.id
        json.sections do
          ex.extractions_extraction_forms_projects_sections.each do |eefps|
            json.set! eefps.extraction_forms_projects_section.section.id do
              json.type1s eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
                t1 = eefpst1.type1
                json.set! t1.id do
                  if eefpst1.type1_type.present?
                    json.type1_type do
                      json.id eefpst1.type1_type.id
                      json.name eefpst1.type1_type.name
                    end
                  end
                  json.name t1.name
                  json.description t1.description

                  json.units = eefpst1.units

                  json.populations do
                    eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |p|
                      json.set! p.population_name.id do
                        json.name p.population_name.name

                        json.result_statistic_sections do
                          jp.result_statistic_sections.each do |rss|
                            json.set! rss.id do
                              json.result_statistic_section_type do
                                json.id rss.result_statistic_section_type.id
                                json.name rss.result_statistic_section_type.name
                              end
                              json.comparisons do
                                comparisons.each m.comparisons do |c|
                                  json.set! c.id do
                                    json.set! :comparison_groups do
                                      c.comparate_groups.each do |cg|
                                        json.set! cg.id do
                                          json.set! :comparates do
                                            cg.comparates.each do |ct|
                                              json.set! ct.id do
                                                json.comparable_elements ct.comparable_elements do |ce|
                                                  json.comparable_type ce.comparable_type
                                                  json.comparable_id ce.comparable_id
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end

                              json.measures do
                                rss.result_statistic_sections_measures.each do |rssm|
                                  m = rssm.measure
                                  json.set! m.id do
                                    json.name m.name

                                    json.array! rssm.comparison_ids do |c|
                                      json.id c.id
                                    end

                   ################# this would create lots of redundancy ############## 
                                    # move it
                                    # but then again

                                    json.records do
                                      json.tps_comparisons_rssms rssm.tps_comparisons_rssms.each do |tcr|
                                        tcr.records.each do |r|
                                          json.set! r.id do
                                            json.timepoint_id tcr.timepoint.id
                                            json.comparison_id tcr.comparison.id
                                            json.record_name r.name
                                          end
                                        end
                                      end
                                      json.tps_arms_rssms rssm.tps_arms_rssms.each do |tar|
                                        tar.records.each do |r|
                                          json.set! r.id do
                                            json.timepoint_id tar.timepoint.id
                                            json.arm_id tar.extractions_extraction_forms_projects_sections_type1.id
                                            json.record_name r.name
                                          end
                                        end
                                      end
                                      json.comparisons_arms_rssms rssm.comparisons_arms_rssms.each do |car|
                                        car.records.each do |r|
                                          json.set! r.id do
                                            json.comparison_id car.comparison.id
                                            json.arm_id car.extractions_extraction_forms_projects_sections_type1.id
                                            json.record_name r.name
                                          end
                                        end
                                      end
                                      json.wacs_bacs_rssms rssm.wacs_bacs_rssms.each do |wbr|
                                        wbr.records.each do |r|
                                          json.set! r.id do
                                            json.wac_id wbr.wac.id
                                            json.bac_id wbr.bac.id
                                            json.record_name r.name
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end

                        json.timepoints do
                          p.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
                            json.set! tp.timepoint_name.id do
                              json.name tp.timepoint_name.name
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end

              if eefps.link_to_type1.present?
                json.linked_type1 eefps.link_to_type1.id
              end

              json.records Record.where(recordable: eefps.extractions_extraction_forms_projects_sections_question_row_column_fields) do |r|
                json.set! r.recordable.question_row_column_field.id do
                  json.name r.name
                end
              end
            end
          end
        end
      end
    end
  end
end
