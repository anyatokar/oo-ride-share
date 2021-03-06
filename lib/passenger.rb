require_relative 'csv_record'

module RideShare
  class Passenger < CsvRecord
    attr_reader :name, :phone_number, :trips

    def initialize(id:, name:, phone_number:, trips: [])
      super(id)

      @name = name
      @phone_number = phone_number
      @trips = trips
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      return nil if trips.empty?

      total = trips.inject(0) do |sum, trip|
        if trip.cost.nil?
          sum + 0
        else
          sum + trip.cost
        end
      end
      return total
    end

    def total_time_spent
      return nil if trips.empty?

      total = trips.inject(0) do |sum, trip|
        if trip.end_time.nil?
          sum + 0
        else
          sum + trip.duration
        end
      end
      return total
    end

    private

    def self.from_csv(record)
      return new(
        id: record[:id],
        name: record[:name],
        phone_number: record[:phone_num]
      )
    end
  end
end
