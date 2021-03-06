require_relative 'test_helper'

describe "Passenger class" do
  describe "Passenger instantiation" do
    before do
      @passenger = RideShare::Passenger.new(id: 1, name: "Smithy", phone_number: "353-533-5334")
    end

    it "is an instance of Passenger" do
      expect(@passenger).must_be_kind_of RideShare::Passenger
    end

    it "throws an argument error with a bad ID value" do
      expect do
        RideShare::Passenger.new(id: 0, name: "Smithy")
      end.must_raise ArgumentError
    end

    it "sets trips to an empty array if not provided" do
      expect(@passenger.trips).must_be_kind_of Array
      expect(@passenger.trips.length).must_equal 0
    end

    it "is set up for specific attributes and data types" do
      [:id, :name, :phone_number, :trips].each do |prop|
        expect(@passenger).must_respond_to prop
      end

      expect(@passenger.id).must_be_kind_of Integer
      expect(@passenger.name).must_be_kind_of String
      expect(@passenger.phone_number).must_be_kind_of String
      expect(@passenger.trips).must_be_kind_of Array
    end
  end


  describe "trips property" do
    before do
      @passenger = RideShare::Passenger.new(
        id: 9,
        name: "Merl Glover III",
        phone_number: "1-602-620-2330 x3723",
        trips: []
        )

      trip = RideShare::Trip.new(
        id: 8,
        passenger: @passenger,
        start_time: Time.new(2016, 8, 8),
        end_time: Time.new(2016, 8, 9),
        rating: 5,
        driver: RideShare::Driver.new(
            id: 1,
            name: "Jill",
            vin: "12345678901234567",
            )
        )

      @passenger.add_trip(trip)
    end

    it "each item in array is a Trip instance" do
      @passenger.trips.each do |trip|
        expect(trip).must_be_kind_of RideShare::Trip
      end
    end

    it "all Trips must have the same passenger's passenger id" do
      @passenger.trips.each do |trip|
        expect(trip.passenger.id).must_equal 9
      end
    end
  end

  describe "net_expenditures" do
    # let block for creating passenger - for last 2 tests
    before do
      @passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: []
      )

      trip = RideShare::Trip.new(
          id: 8,
          passenger: @passenger,
          start_time: Time.new(2016, 8, 8),
          end_time: Time.new(2016, 8, 9),
          rating: 5,
          cost: 32.5,
          driver: RideShare::Driver.new(
              id: 1,
              name: "Jill",
              vin: "12345678901234567",
              )
      )

      @passenger.add_trip(trip)
      @passenger.add_trip(trip)
    end

    it "returns 0 for empty array" do
      passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: []
      )
      # create instance of passenger with empty array!
      expect(passenger.net_expenditures).must_be_nil
    end

    it "return numeric value" do
      expect(@passenger.net_expenditures).must_be_kind_of Numeric
    end

    it "returns sum of all trip costs for passenger" do
      expect(@passenger.net_expenditures).must_equal 65
    end

    it "it ignores any in-progress trips" do
      in_progress_trip = RideShare::Trip.new(
          id: 8,
          passenger: @passenger,
          start_time: Time.new(2019, 10, 10, 10, 0),
          end_time: nil,
          rating: nil,
          cost: nil,
          driver: RideShare::Driver.new(
              id: 1,
              name: "Jill",
              vin: "12345678901234567",
              )
      )
      @passenger.add_trip(in_progress_trip)

      expect(@passenger.net_expenditures).must_equal 65
    end
  end
  describe "total_time_spent" do
    before do
      @passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: []
      )
      trip = RideShare::Trip.new(
          id: 8,
          passenger: @passenger,
          start_time: Time.new(2019, 10, 10, 10, 0),
          end_time: Time.new(2019, 10, 10, 10, 5),
          rating: 5,
          cost: 32.5,
          driver: RideShare::Driver.new(
              id: 1,
              name: "Jill",
              vin: "12345678901234567",
              )
      )

      @passenger.add_trip(trip)
      @passenger.add_trip(trip)
    end

    it "it returns nil if no trips were taken" do
      passenger = RideShare::Passenger.new(
          id: 9,
          name: "Merl Glover III",
          phone_number: "1-602-620-2330 x3723",
          trips: [])
      expect(passenger.total_time_spent).must_be_nil
    end

    it "it returns a numeric value" do
      expect(@passenger.total_time_spent).must_be_kind_of Numeric
    end

    it "returns the sum of all trip durations for a passenger" do
      expect(@passenger.total_time_spent).must_equal 600
    end

    it "ignores any in-progress trip" do
      in_progress_trip = RideShare::Trip.new(
          id: 8,
          passenger: @passenger,
          start_time: Time.new(2019, 10, 10, 10, 0),
          end_time: nil,
          rating: nil,
          cost: nil,
          driver: RideShare::Driver.new(
              id: 1,
              name: "Jill",
              vin: "12345678901234567",
              )
      )
      @passenger.add_trip(in_progress_trip)
      expect(@passenger.total_time_spent).must_equal 600
    end
  end
end
