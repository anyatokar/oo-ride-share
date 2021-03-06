require_relative 'test_helper'

TEST_DATA_DIRECTORY = 'test/test_data'

describe "TripDispatcher class" do
  def build_test_dispatcher
    return RideShare::TripDispatcher.new(
      directory: TEST_DATA_DIRECTORY
    )
  end

  describe "Initializer" do
    it "is an instance of TripDispatcher" do
      dispatcher = build_test_dispatcher
      expect(dispatcher).must_be_kind_of RideShare::TripDispatcher
    end

    it "establishes the base data structures when instantiated" do
      dispatcher = build_test_dispatcher
      [:trips, :passengers].each do |prop|
        expect(dispatcher).must_respond_to prop
      end

      expect(dispatcher.trips).must_be_kind_of Array
      expect(dispatcher.passengers).must_be_kind_of Array
      expect(dispatcher.drivers).must_be_kind_of Array
    end

    it "loads the development data by default" do
      # Count lines in the file, subtract 1 for headers
      trip_count = %x{wc -l 'support/trips.csv'}.split(' ').first.to_i - 1

      dispatcher = RideShare::TripDispatcher.new

      expect(dispatcher.trips.length).must_equal trip_count
    end
  end

  describe "passengers" do
    describe "find_passenger method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect{ @dispatcher.find_passenger(0) }.must_raise ArgumentError
      end

      it "finds a passenger instance" do
        passenger = @dispatcher.find_passenger(2)
        expect(passenger).must_be_kind_of RideShare::Passenger
      end
    end

    describe "Passenger & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads passenger information into passengers array" do
        first_passenger = @dispatcher.passengers.first
        last_passenger = @dispatcher.passengers.last

        expect(first_passenger.name).must_equal "Passenger 1"
        expect(first_passenger.id).must_equal 1
        expect(last_passenger.name).must_equal "Passenger 8"
        expect(last_passenger.id).must_equal 8
      end

      it "connects trips and passengers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.passenger).wont_be_nil
          expect(trip.passenger.id).must_equal trip.passenger_id
          expect(trip.passenger.trips).must_include trip
        end
      end
    end
  end

  describe "drivers" do
    describe "find_driver method" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "throws an argument error for a bad ID" do
        expect { @dispatcher.find_driver(0) }.must_raise ArgumentError
      end

      it "finds a driver instance" do
        driver = @dispatcher.find_driver(2)
        expect(driver).must_be_kind_of RideShare::Driver
      end
    end

    describe "Driver & Trip loader methods" do
      before do
        @dispatcher = build_test_dispatcher
      end

      it "accurately loads driver information into drivers array" do
        first_driver = @dispatcher.drivers.first
        last_driver = @dispatcher.drivers.last

        expect(first_driver.name).must_equal "Driver 1 (unavailable)"
        expect(first_driver.id).must_equal 1
        expect(first_driver.status).must_equal :UNAVAILABLE
        expect(last_driver.name).must_equal "Driver 3 (no trips)"
        expect(last_driver.id).must_equal 3
        expect(last_driver.status).must_equal :AVAILABLE
      end

      it "connects trips and drivers" do
        dispatcher = build_test_dispatcher
        dispatcher.trips.each do |trip|
          expect(trip.driver).wont_be_nil
          expect(trip.driver.id).must_equal trip.driver_id
          expect(trip.driver.trips).must_include trip
        end
      end
    end
  end
  describe "request_trip" do
    before do
      @trip_dispatcher = build_test_dispatcher
    end
    it "returns Trip instance" do
      expect(@trip_dispatcher.request_trip(1)).must_be_instance_of RideShare::Trip
    end

    it "creates a unique instance of Trip" do
      before_request = @trip_dispatcher.trips.dup
      new_trip = @trip_dispatcher.request_trip(1)
      expect(before_request.length).must_equal @trip_dispatcher.trips.length - 1
      expect(before_request).wont_include new_trip
    end

    it "updates all trip collections appropriately" do
      previous_trips_qty = @trip_dispatcher.trips.length
      prev_passenger_trip_qty = @trip_dispatcher.passengers[0].trips.length
      prev_driver_trips_qty = @trip_dispatcher.drivers[2].trips.length
      new_trip = @trip_dispatcher.request_trip(1)
      passenger = @trip_dispatcher.find_passenger(1)
      driver = new_trip.driver

      expect(prev_driver_trips_qty).must_equal driver.trips.length - 1
      expect(prev_passenger_trip_qty).must_equal passenger.trips.length - 1
      expect(previous_trips_qty).must_equal @trip_dispatcher.trips.length - 1
      expect(driver.trips).must_include new_trip
      expect(passenger.trips).must_include new_trip
      expect(@trip_dispatcher.trips).must_include new_trip
    end

    it "selects an available driver" do
      available_drivers = @trip_dispatcher.drivers.select { |driver| driver.status == :AVAILABLE }
      new_trip = @trip_dispatcher.request_trip(1)

      expect(available_drivers).must_include new_trip.driver
    end

    it "updates selected driver's status appropriately" do
      new_trip = @trip_dispatcher.request_trip(1)

      expect(new_trip.driver.status).must_equal :UNAVAILABLE
    end

    it "selects a driver with no trips " do
      new_trip= @trip_dispatcher.request_trip(1)

      expect(new_trip.driver_id).must_equal 3
    end

    it "selects a driver that has gone longest without a trip" do
      @trip_dispatcher.drivers.delete_at(2)
      new_driver = RideShare::Driver.new(
          id: 4,
          name: "Driver 4 a long time since last trip",
          vin: "12345678901234567",
          status: :AVAILABLE
      )
      @trip_dispatcher.drivers << new_driver
      new_trip = RideShare::Trip.new(
          id: 100,
          passenger_id: 100,
          cost: 500,
          rating: 5,
          driver: new_driver,
          start_time: Time.new(1900, 01, 01),
          end_time: Time.new(1900, 01, 02)
      )
      new_driver.trips << new_trip

      requested_trip = @trip_dispatcher.request_trip(1)

      expect(requested_trip.driver).must_be_same_as new_driver
    end

    it "raises an ArgumentError if there are no available drivers" do
      @trip_dispatcher.drivers.delete_if { |driver| driver.status == :AVAILABLE }

      expect{
        @trip_dispatcher.request_trip(1)
      }.must_raise ArgumentError
    end
  end
end
