require 'net/http'
require 'json'
require 'rest_client'
class UsersController < ApplicationController  

  def index

  end
  
  def viewMyResellers
    @myResellers = DB[:resellers3]
    respond_to do |format|
      format.html
        format.json { render json: @myResellers }
    end
  end

  def addPayment

    temp_payment = params[:payment_amount]
    payment_note = params[:payment_note]
    payment = temp_payment.to_f #changed payment to float
    temp_hash = params[:resellers3]
    if payment <= 0 
      flash[:error_payment] = "Payment should be great than 0"
    end
    @myResellers = DB[:resellers3]
    @id = DB[:resellers3].where(:login => temp_hash["login"]).first[:id]
    @actual_value = DB[:resellers3].where(:id => @id).first[:callsLimit]
    payment_insertion = DB[:resellerspayments].where(:id_reseller => @id)
    payment_insertion.insert(:money => payment, :id_reseller => @id, :data => Time.now(), :type => 1, :description => "", :actual_value => @actual_value, :resellerlevel => 3)
    
    payment_update = DB[:resellers3].where(:id => @id)
    payment_update.update(:callsLimit => :callsLimit + payment)
    
    flash[:notice_payment] = "Payment successfully added!"
    redirect_to "/users/viewMyResellers"
  end

  def addReseller3
    # go to table tariffreseller and give me the list of id_tariff whose resellerlevel is empty string
    # and then pass it to the view for a drop down selection
    # put the list of the id_tariffs in a variable named @id_tariffs
    
    reseller_tariffs = DB[:tariffreseller]
    all_tariffs = DB[:tariffsnames]
    user_tariff_ids = []
    all_tariffs_array = []
    reseller_tariffs_array = []

    all_tariffs.each do |t|
      all_tariffs_array.push(t[:id_tariff])
    end
    reseller_tariffs.each do |t|
      reseller_tariffs_array.push(t[:id_tariff])
    end

    user_tariff_ids = (all_tariffs_array - reseller_tariffs_array)
    
    @tariff_names = []
    names = []
    user_tariff_ids.each do |id|
     names.push(DB[:tariffsnames].where(:id_tariff => id))
    end
    names.each do |n|
      @tariff_names.push(n.first[:description]) rescue nil
    end
  end

  def addReseller3Submit
    #to begin with, we are passing only limited fields.

    @login = params[:login] #required
    @password = params[:password] #required
    # consused?
    #@type = params[:type] #required
    #we will grap the id_tariff from the drop down list 
    temp_hash = params[:reseller3]
    @id_tariff = DB[:tariffsnames].where(:description => temp_hash["description"]).first[:id_tariff] rescue nil
    @callsLimit = params[:callsLimit] #required
    @clientsLimit = params[:clientsLimit] #required
    #@tech_prefix = params[:tech_prefix] #required
    @identifier =   params[:identifier] #required
    
    # we will not pass the following for now
    @Fullname = params[:Fullname] || ""#required
    @Address = params[:Address] || "" #required
    @City = params[:City] || ""#required
    @ZipCode = params[:ZipCode] || "" #required
    @Country = params[:Country] || "" #required
    @Phone = params[:Phone] || ""#required
    @Email = params[:Email] || ""#required
    @TaxID = params[:TaxID] #required 
    #@type2 = params[:type2] || 0#required 
    @language = params[:language] || ""#required

    @tech_prefix = DB[:resellers3].where(:id => 3).first[:tech_prefix]

    new_reseller = DB[:resellers3]
    new_reseller.insert(:login => @login, :password => @password, :type => @tyoe, :id_tariff => @id_tariff, :callsLimit => @callsLimit,
                        :clientsLimit => @clientsLimit,  :tech_prefix => @tech_prefix, :identifier => @identifier, :Fullname => @Fullname,
                        :Address => @Address, :City => @City, :ZipCode => @ZipCode, :Country => @Country, :Phone => @Phone, :Email => @Email,
                        :TaxID => "", :type2 => 0, :language => @language, :type => 49601)
  end

  def tariffs
    # this is not yet complete....
    reseller_tariffs = DB[:tariffreseller]
    all_tariffs = DB[:tariffsnames]
    user_tariff_ids = []
    all_tariffs_array = []
    reseller_tariffs_array = []

    all_tariffs.each do |t|
      all_tariffs_array.push(t[:id_tariff])
    end
    reseller_tariffs.each do |t|
      reseller_tariffs_array.push(t[:id_tariff])
    end

    user_tariff_ids = (all_tariffs_array - reseller_tariffs_array)
    
    @tariffs = []
    user_tariff_ids.each do |id|
     @tariffs.push(DB[:tariffsnames].where(:id_tariff => id))
    end
  end

  def addRatesToTariff
    @tariffs = []
    @tariff_id = params[:tariff][:id_tariff]
    @tariffs = DB[:tariffs].where(:id_tariff => @tariff_id)
    @index = params[:index] || 20
  end

  def show
  end

end
