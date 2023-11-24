require 'ideal_postcodes'

# Controller concern to enable reusable postcode lookup methods
module PostcodeLookup
  extend ActiveSupport::Concern
  include PostcodeHelper
  included do
    before_action :set_api_key
  end

  class IdealPostcodesGenericError < StandardError; end

  # Assigns address-related attributes to the record param object
  # based on the response from an IdealPostcodes API lookup.
  # Attributes are assigned here in order to populate the input fields
  # on the following view.
  # @param [ApplicationRecord] record : An instance of ApplicationRecord -
  # of type User, Organisation or Project
  # @return record
  def assign_attributes(record)

    # Rails.cache.fetch both reads and writes from the cache. If we fail to
    # retrieve our address details from the cache here, then we call the
    # lookup_address method and assign it to the cache
    udprn = params[:address]
    @address_response = Rails.cache.fetch(udprn.to_s) do
      logger.info 'Address not found in cache, calling API using UDPRN: ' \
                  "#{udprn}"
      lookup_address(udprn)
    end

    record.assign_attributes(
      {
        line1: @address_response[:line_1],
        line2: @address_response[:line_2],
        line3: @address_response[:line_3],
        postcode: @address_response[:postcode],
        townCity: @address_response[:post_town],
        county: @address_response[:county]
      }
    )

  end

  # Makes a request to the IdealPostcodes API to retrieve a list of addresses
  # matching the given postcode.
  # If no postcode or an invalid postcode is found, this method redirects the
  # user back to the current view.
  def display_address_search_results

    if params['postcode']['lookup'].present?
      postcode = params['postcode']['lookup']
      if validate_postcode_format(postcode)
        lookup_postcode_and_render_results(postcode)
      else
        logger.error 'Invalid postcode format entered'
        redirect_with_errors t('errors.invalid_postcode', postcode: postcode)

      end
    else
      logger.error 'No postcode entered when searching for an address'
      redirect_with_errors t('postcode.enter_a_postcode')
    end
  end

  private

  # calls lookup postcode to get a list of addresses for the postcode
  # populates the addresses into @response_array which is referred to when
  # :address_results is rendered.
  # @param [String] postcode : A string for a postcode
  def lookup_postcode_and_render_results(postcode)

    @response_array = lookup_postcode(postcode)

    if @response_array.empty?

      logger.info 'No results found when searching for postcode' \
            "#{postcode}"

      redirect_with_errors 'No results found for postcode ' \
            "#{postcode}"

    else

      render :address_results

    end

  end

  # Sets the IdealPostcodes.api_key value
  def set_api_key
    IdealPostcodes.api_key = Rails.configuration.x.ideal_postcodes.api_key
  end

  # performs the redirect if a problem is found in postcode validation
  def redirect_with_errors(postcode_error_string)

    redirect_to(
      :postcode,
      flash: {
        errors: {
          postcode: postcode_error_string
        }
      }
    )

  end

  # Looks up a postcode from the Ideal Postcodes API.
  # If the api returns an error, then log the HTTP response
  # code and API error code.  Then show the user a 500 page.
  # @param [String] postcode : A string representing a postcode
  # @return [array] response_array: An unformatted array of address results
  def lookup_postcode(postcode)

    response_array = IdealPostcodes::Postcode.lookup postcode

    cache_address_results(response_array)

    response_array

  rescue IdealPostcodes::IdealPostcodesError => e

    logger.error "Error in Ideal Postcodes API.  Response body was: #{e.http_body} " \
      "and HTTP code was:  #{e.http_code} and error code was: #{e.response_code}"

    raise

  rescue => e

    logger.error e.to_s

    raise(IdealPostcodesGenericError, 'Unknown exception when calling ' \
      "IdealPostcodes API during lookup_postcode for #{@type} ID: " \
      "#{@model_object.id}")

  end

  # Looks up an Address from the Ideal Postcodes API. If the API returns an
  # error, then log the HTTP response code and API error code. Then show the
  # user a 500 page.
  #
  # This method exists so that if the cache had been cleared when a user
  # selected an address, then the control flow will fallback to using the UDPRN
  # to find the address via an API lookup.
  # @param [string] udprn : A Unique Delivery Point Reference Number as a string
  # @return [hash] A hash representing a single address determined from the udprn.
  def lookup_address(udprn)

    IdealPostcodes::Address.lookup udprn

  rescue IdealPostcodes::IdealPostcodesError => e

    logger.error "Error in Ideal Postcodes API.  Response body was: #{e.http_body} " \
      "and HTTP code was:  #{e.http_code} and error code was: #{e.response_code}"

    raise

  rescue => e

    logger.error e.to_s

    raise(IdealPostcodesGenericError, 'Unknown exception when calling ' \
      "IdealPostcodes API during lookup_address for #{@type} ID: " \
      "#{@model_object.id}")

  end

  # Puts each value from @response_array into a cache.  The UDPRN is the key and
  # the remaining address details the value.  This enables the cached addresses
  # to be referred to and selected later in the user journey.
  # @param [array] response_array : an array of addresses
  def cache_address_results(response_array)
    response_array.each do |result|
      # Cache the result fields under a key of the current UDPRN
      Rails.cache.fetch(result[:udprn].to_s, expires_in: 5.minutes) do
        logger.debug "Writing to cache for result #{result[:udprn]}"
        {
          line_1: result[:line_1],
          line_2: result[:line_2],
          line_3: result[:line_3],
          post_town: result[:post_town],
          county: result[:county],
          postcode: result[:postcode]
        }
      end
    end
  end

end
