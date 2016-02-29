class Umrdr::SearchBuilder < Sufia::SearchBuilder

  # show both works that match the query and works that contain files that match the query
  def show_works_or_works_that_contain_files(solr_parameters)
    return if solr_parameters[:q].blank?
    solr_parameters[:user_query] = extract_user_query(solr_parameters[:q])
    solr_parameters[:q] = new_query
  end

  protected

    def extract_user_query(query)
      @user_params = ''
      user_params, user_query = query.split('}')
      if user_query
        @user_params = user_params.split('{')[1].sub('!', '').sub('dismax ', '')
      else
        user_query = user_params
      end
      user_query
    end

    # the {!dismax} causes the query to go against the query fields
    def dismax_query
      ## "{!dismax v=$user_query}"
      "{!dismax #{@user_params} v=$user_query}"
    end
end
