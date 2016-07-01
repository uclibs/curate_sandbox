module ParamsHelper

  # This method is called before the search_as_hidden_fields method to wipe
  # out any parameters that are "unknown" to the application.  This should
  # resolve the cross-site scripting warning generated by UC's Hailstorm scan.

  def scrub_params(params)
    safe_params = Hash.new;

    unless params["f"].nil?
      safe_params["f"] = Hash.new;
      safe_params["f"]["collection_sim"] = params["f"]["collection_sim"]
      safe_params["f"]["desc_metadata__creator_sim"] = params["f"]["desc_metadata__creator_sim"]
      safe_params["f"]["desc_metadata__language_sim"] = params["f"]["desc_metadata__language_sim"]
      safe_params["f"]["desc_metadata__publisher_sim"] = params["f"]["desc_metadata__publisher_sim"]
      safe_params["f"]["desc_metadata__subject_sim"] = params["f"]["desc_metadata__subject_sim"]
      safe_params["f"]["generic_type_sim"] = params["f"]["generic_type_sim"]
      safe_params["f"]["human_readable_type_sim"] = params["f"]["human_readable_type_sim"]
      safe_params["per_page"] = params["per_page"]
      safe_params["sort"] = params["sort"]
    end

    unless params["q"].nil?
      safe_params["q"] = params["q"]
    end

    safe_params["controller"] = params["controller"]
    safe_params["action"] = params["action"]
    safe_params["works"] = params["works"]

    params.clear

    unless safe_params["f"].nil?
      params["f"] = Hash.new
      params["f"]["collection_sim"] = safe_params["f"]["collection_sim"] unless safe_params["f"]["collection_sim"].nil?
      params["f"]["desc_metadata__creator_sim"] = safe_params["f"]["desc_metadata__creator_sim"] unless safe_params["f"]["desc_metadata__creator_sim"].nil?
      params["f"]["desc_metadata__language_sim"] = safe_params["f"]["desc_metadata__language_sim"] unless safe_params["f"]["desc_metadata__language_sim"].nil?
      params["f"]["desc_metadata__publisher_sim"] = safe_params["f"]["desc_metadata__publisher_sim"] unless safe_params["f"]["desc_metadata__publisher_sim"].nil?
      params["f"]["desc_metadata__subject_sim"] = safe_params["f"]["desc_metadata__subject_sim"] unless safe_params["f"]["desc_metadata__subject_sim"].nil?
      params["f"]["generic_type_sim"] = safe_params["f"]["generic_type_sim"] unless safe_params["f"]["generic_type_sim"].nil?
      params["f"]["human_readable_type_sim"] = safe_params["f"]["human_readable_type_sim"] unless safe_params["f"]["human_readable_type_sim"].nil?
      params["per_page"] = safe_params["per_page"] unless safe_params["per_page"].nil?
      params["sort"] = safe_params["sort"] unless safe_params["sort"].nil?
    end

    unless safe_params["q"].nil?
      params["q"] = safe_params["q"] unless safe_params["q"].nil?
    end

    params["controller"] = safe_params["controller"] unless safe_params["controller"].nil?
    params["action"] = safe_params["action"] unless safe_params["action"].nil?
    params["works"] = safe_params["works"] unless safe_params["works"].nil?
  end

  def check_parameters?

    return_404 unless params[:page].to_i.to_s == params[:page] or params[:page].nil?
    return_404 unless params[:page].to_i < 1000
    return_404 if params[:page] && params[:page].to_i < 1

    return_404 unless params[:per_page].to_i.to_s == params[:per_page] or params[:per_page].nil?
    return_404 unless params[:per_page].to_i < 1000
    return_404 if params[:per_page] && params[:per_page].to_i < 1

    limit_param_length(params[:q], 1000) unless defined?(params[:q]) == nil
    limit_param_length(params["f"]["desc_metadata__creator_sim"], 1000) unless defined?(params["f"]["desc_metadata__creator_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__language_sim"], 1000) unless defined?(params["f"]["desc_metadata__language_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__publisher_sim"], 1000) unless defined?(params["f"]["desc_metadata__publisher_sim"]) == nil
    limit_param_length(params["f"]["desc_metadata__subject_sim"], 1000) unless defined?(params["f"]["desc_metadata__subject_sim"]) == nil
    limit_param_length(params["f"]["generic_type_sim"], 1000) unless defined?(params["f"]["generic_type_sim"]) == nil
    limit_param_length(params["f"]["human_readable_type_sim"], 1000) unless defined?(params["f"]["human_readable_type_sim"]) == nil
    limit_param_length(params["utf8"], 1000) unless defined?(params["utf8"]) == nil
    limit_param_length(params["works"], 1000) unless defined?(params["works"]) == nil
    limit_param_length(params["collectible_id"], 1000) unless defined?(params["collectible_id"]) == nil
    limit_param_length(params["profile_collection_id"], 1000) unless defined?(params["profile_collection_id"]) == nil

    limit_param_length(params["hydramata_group"]["members_attributes"]["0"]["id"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["0"]["id"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["1"]["id"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["1"]["id"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["0"]["_destroy"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["0"]["_destroy"]) == nil
    limit_param_length(params["hydramata_group"]["members_attributes"]["1"]["_destroy"], 100) unless defined?(params["hydramata_group"]["members_attributes"]["1"]["_destroy"]) == nil

    Curate.configuration.registered_curation_concern_types.each do |work_type|
      work = work_type.underscore

      limit_param_length(params[work]["editors_attributes"]["0"]["id"], 100) unless defined?(params[work]["editors_attributes"]["0"]["id"]) == nil
      limit_param_length(params[work]["editors_attributes"]["1"]["id"], 100) unless defined?(params[work]["editors_attributes"]["1"]["id"]) == nil
      limit_param_length(params[work]["editor_groups_attributes"]["0"]["id"], 100) unless defined?(params[work]["editor_groups_attributes"]["0"]["id"]) == nil
      limit_param_length(params[work]["editor_groups_attributes"]["1"]["id"], 100) unless defined?(params[work]["editor_groups_attributes"]["1"]["id"]) == nil

      validate_embargo_date(work)
    end
  end

  def check_blind_sql_parameters_loop?()
    params.clone.each do |key, value|
        if value.is_a?(Hash)
          value.clone.each do |k,v|
            unless defined?(v) == nil
              if v.to_s.include?('waitfor delay') || v.to_s.include?('DBMS_LOCK.SLEEP') || v.to_s.include?('SLEEP(5)') || v.to_s.include?('SLEEP(10)')
                return_404
                return false
                break
              end
            end
          end
        else
          unless defined?(value) == nil
            if value.to_s.include?('waitfor delay') || value.to_s.include?('DBMS_LOCK.SLEEP') || value.to_s.include?('SLEEP(5)') || value.to_s.include?('SLEEP(10)')
              return_404
              return false
              break
            end
          end
        end
    end
  end

  def scan_params(param, blacklist)
    if blacklist.any? { |w| param.to_s =~ /#{w}/i }
      return true
    end
  end

  def params_contain_blacklisted_strings?()
    blacklist = ['<[^>]*script']
    params.clone.each do |key, value|
        if value.is_a?(Hash)
          value.clone.each do |k,v|
            unless defined?(v) == nil
              if scan_params(v, blacklist)
                flash[:error] = 'HTML script tags not permitted'
                render :new and return
              end
            end
          end
        else
          unless defined?(value) == nil
              if scan_params(value, blacklist)
                flash[:error] = 'HTML script tags not permitted'
              render :new and return
            end
          end
        end
    end
  end

  def check_java_script_parameters?()
    blacklist = ['javascript:alert']
    params.clone.each do |key, value|
        if value.is_a?(Hash)
          value.clone.each do |k,v|
            unless defined?(v) == nil
              if scan_params(v, blacklist)
                return_404
                return false
                break
              end
            end
          end
        else
          unless defined?(value) == nil
              if scan_params(value, blacklist)
              return_404
              return false
              break
            end
          end
        end
    end
  end

  protected

  def limit_param_length(parameter, length_limit)
    return_404 unless parameter.to_s.length < length_limit
  end

  def return_404
    render(:file => File.join(Rails.root, 'public/404.html'), :status => 404)
  end

  private

  def limit_param_length(parameter, length_limit)
    return_404 unless parameter.to_s.length < length_limit
  end

  def validate_embargo_date(work)
    unless (defined?(params[work]['embargo_release_date'])).nil?
      return_404 unless params[work]['embargo_release_date'] =~ /\d{4}-\d{2}-\d{2}/ || params[work]['embargo_release_date'].blank?
    end
  end
end
