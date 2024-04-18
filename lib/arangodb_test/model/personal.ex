defmodule ArangodbTest.Model.Personal do
  use ArangoXEcto.Schema
    import Ecto.Changeset
    alias ErpHr.Model.PersonalDeclaration

    @hiring_required_fields [:name, :surname, :tax_code, :residence, :private_email]
    @iban_regex ~r/^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$/
    @swift_regex ~r/^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/
    @mobile_phone_regex ~r/^[\+[0-9]{0,4}]?[0-9]{10}$/
    @email_regex ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/

    schema "employee" do
      field :description, :string
      field :registration_number, :string
      field :main_work_place, :string
      field :public_selection, :string
      field :public_selection_date, :string
      field :name, :string
      field :surname, :string
      field :employee_name, :string
      field :private_mobile, :string
      field :private_email, :string
      field :private_address, :string
      field :job_position, :string
      field :sim_transfer, :boolean
      field :email, :string
      field :birth_date, :date
      field :tax_code, :string
      field :iban, :string
      field :creator_username, :string
      field :modifier_username, :string
      field :notes, :string
      field :place_available, :boolean
      field :department, :string
      field :role, :string
      field :area, :string
      field :subarea, :string
      field :management, :string
      field :manager, :string
      field :tutor, :string
      field :assignments, :string
      field :frequent_trips, :string
      field :places_of_work, {:array, :string}
      field :office, :string
      field :phone, :integer
      field :cost_center, :string
      field :contract, :string
      field :scheduled_hiring_date, :date
      field :hiring_date, :date
      field :resignation_date, :date
      field :clearing_out_date, :date
      field :classification, :string
      field :employment, :string
      # field :gross_salary, Arangodb.EctoCurrency
      field :overtime_flat_rate, :string
      field :overtime_amount, :integer
      field :equipment, {:array, :string}
      field :projects, {:array, :string}
      field :shared_mailboxes, {:array, :string}
      field :public_folders, {:array, :string}
      field :reason, :string
      field :replacement_of, :string
      field :absent_for, :string
      field :absent_for_other, :string
      field :maternity_start, :date
      field :maternity_end, :date
      field :employee_sid, :string
      field :credit_card_plafond, :integer
      field :envelope, :string # provvisorio per gestione buste badge e password
      field :official_role, :string
      # embeds_many :part_times, ErpHr.Model.PartTime
      field :status, :string
      field :effective_date, :date
      field :old_manager, :string
      field :new_reports, {:array, :string}
      field :stop_and_go, :boolean
      field :external, :boolean
      field :mailbox_deletion_date, :string
      field :ombis, :string
      # qui sotto i campi nuovi per funzionalità hiring
      field :born_in, :string
      field :residence, :string
      field :zip, :string
      field :communications_language, :string
      field :bank, :string
      field :bank_branch, :string
      field :swift, :string
      embeds_one :declaration, PersonalDeclaration, on_replace: :update
      timestamps()
    end

    def changeset_new(personal, params \\ %{}) do
      personal
      |> cast(params, [:description, :manager, :scheduled_hiring_date, :main_work_place, :replacement_of, :notes])
      |> validate_required([:description, :manager, :scheduled_hiring_date, :main_work_place])
    end

    def changeset_hiring(personal, params \\ %{}) do
      personal
      |> cast(params, [:name, :surname, :birth_date, :tax_code, :born_in, :private_mobile, :private_email, :private_address,
      :residence, :zip, :communications_language, :bank, :bank_branch, :iban, :swift])
      |> cast_embed(:declaration)
      |> unique_constraint(:surname, name: "idx_1792236777377890304", message: "This employee already exists")
      # |> unique_constraint(:employee_name_index)
      |> validate_required(@hiring_required_fields)
      |> update_change(:tax_code, &String.upcase/1)
      |> validate_length(:tax_code, is: 16)
      |> validate_fiscal_code(:tax_code)
      |> maybe_force_birth_date()
      # |> validate_zip_code(:zip)
      # |> unique_constraint(:name, name: "idx_1685137229031145472", message: "This employee already exists")
      |> remove_spaces(:iban)
      |> validate_format(:iban, @iban_regex, message: "is not a valid IBAN")
      |> remove_spaces(:swift)
      |> validate_format(:swift, @swift_regex, message: "is not a valid SWIFT")
      |> validate_format(:private_mobile, @mobile_phone_regex, message: "is not a valid phone number")
      |> validate_format(:private_email, @email_regex, message: "is not a valid email")
      |> capitalize_per_word(:name)
      |> capitalize_per_word(:surname)
    end

    defp remove_spaces(changeset, field) do
      case get_field(changeset, field) do
        nil -> changeset
        value ->
          new_value = String.replace(value, ~r/\s+/, "")
          put_change(changeset, field, new_value)
      end
    end

    def capitalize_per_word(changeset, field) do
      string = get_field(changeset, field)
      if string != nil do
        string = string
            |> String.split
            |> Enum.map(&String.capitalize/1)
            |> Enum.join(" ")
            |> String.trim()
        changeset
          |> force_change(field, string)
      else
        changeset
      end
    end

    defp validate_fiscal_code(changeset, field, _options \\ []) do
      validate_change(changeset, field, fn _, code ->
      #code = get_field(changeset, field)
      if code == nil or String.length(code) < 16 or !Regex.match?(~r/^[A-Z0-9]{16}$/, code) do
        # []
        [{field, "Invalid"}]
      else


        cin_odds = %{
        "0" => 1, "1" => 0, "2" => 5, "3" => 7, "4" => 9,
        "5" => 13, "6" => 15, "7" => 17, "8" => 19, "9" => 21,
        "A" => 1, "B" => 0, "C" => 5, "D" => 7, "E" => 9,
        "F" => 13, "G" => 15, "H" => 17, "I" => 19, "J" => 21,
        "K" => 2, "L" => 4, "M" => 18, "N" => 20, "O" => 11,
        "P" => 3, "Q" => 6, "R" => 8, "S" => 12, "T" => 14,
        "U" => 16, "V" => 10, "W" => 22, "X" => 25, "Y" => 24,
        "Z" => 23
        }

        cin_evens = %{
        "0" => 0, "1" => 1, "2" => 2, "3" => 3, "4" => 4,
        "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9,
        "A" => 0, "B" => 1, "C" => 2, "D" => 3, "E" => 4,
        "F" => 5, "G" => 6, "H" => 7, "I" => 8, "J" => 9,
        "K" => 10, "L" => 11, "M" => 12, "N" => 13, "O" => 14,
        "P" => 15, "Q" => 16, "R" => 17, "S" => 18, "T" => 19,
        "U" => 20, "V" => 21, "W" => 22, "X" => 23, "Y" => 24,
        "Z" => 25
        }

        alphabet = Enum.map(Enum.to_list(?A..?Z), fn(n) -> <<n>> end)
        num = Enum.to_list(0..25)
        alphabet_map = Enum.zip(num, alphabet) |> Enum.into(%{})


        cin = code |> String.last()
        graphemes = code
                |> String.graphemes()
                |> Enum.take(15)


        sum = graphemes
                |> Enum.with_index
                |> Enum.map(fn {x, i} -> if rem(i+1, 2) == 1 do cin_odds[x] else cin_evens[x]  end end)
                |> Enum.sum()

        reminder = rem(sum, 26)
        control_letter = alphabet_map[reminder]

        if control_letter == cin do
          [] # true
        else
          [{field, "Invalid control character!"}] # false
        end
      end
      end)
    end

    def maybe_force_birth_date(changeset) do
      case changeset.errors do
        [{:tax_code, _} | _] ->
          # The changeset has an error on the tax_code field
          changeset
        _ ->
          # The changeset does not have an error on the tax_code field
          changeset |> force_change(:birth_date, fiscal_code_to_birth_date(changeset |> get_field(:tax_code)))
      end

    end

    def fiscal_code_to_birth_date(fiscal_code) when is_nil(fiscal_code) do
      ""
    end

    def fiscal_code_to_birth_date(fiscal_code) do
      curent_year = Date.utc_today.year
      year = fiscal_code |> String.slice(6, 2)
      possible_year = (year |> String.to_integer) + 2000
      year_final =
        case possible_year > curent_year do
          true -> possible_year - 100
          _ -> possible_year
        end

      month_char = fiscal_code |> String.slice(8, 1)
      month_map = %{
        "A" => "01",
        "B" => "02",
        "C" => "03",
        "D" => "04",
        "E" => "05",
        "H" => "06",
        "L" => "07",
        "M" => "08",
        "P" => "09",
        "R" => "10",
        "S" => "11",
        "T" => "12"
      }
      month_string = month_map |> Map.get(month_char)

      day = fiscal_code |> String.slice(9, 2) |> String.to_integer()
      day_string =
        case day > 40 do
          true -> (day - 40)
          _ -> day
        end
        |> to_string()
        |> String.pad_leading(2, "0")


      # Enum.join([year_string, month_string, day_string], "-")
      Date.new!(year_final, month_string |> String.to_integer(), day_string |> String.to_integer())

    end

    # defp validate_zip_code(changeset, field) do
    #   require ErpHrWeb.Gettext
    #   value = get_field(changeset, field) || ""

    #   case Regex.match?(~r/^\d{5}$/, value) do
    #     true -> changeset
    #     false -> add_error(changeset, field, ErpHrWeb.Gettext.dgettext("errors", "must be a %{value}-digit number", value: "5"))
    #     #HelloWeb.Gettext.dgettext("errors", "must be at least %{value}", value: "#{min_value}")
    #     # Gettext.dgettext(ErpHrWeb.Gettext, "errors", "Zip code must be a 5-digit number"))
    #   end
    # end

    def required_fields_for_hiring() do
      ErpHr.Model.Personal.__schema__(:fields)
      |> Enum.filter(fn field -> field in @hiring_required_fields end)
    end
end
