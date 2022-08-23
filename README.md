## EnvíaYa - Programming skills test

Thank you very much for your interest in joining our development team. We would be very happy to welcome you, if you posses all required skills. In order to get to know your programming skills in more detail, we kindly ask you to complete this test task.

## Task description

EnvíaYa is a shipping integration software. As such, postal code and address information is crucial for our business. We manage this information in several tables:
- Country_data (Countries)
- States
- Cities
- Municipalities
- Neighborhoods (Colonias in Mexico)

These tables are related to each other, in a top to bottom order. 

The mexican postal code services provide this information on a monthly basis in form of a single Excel file, which can be downloaded here: https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/CodigoPostal_Exportar.aspx

The task is to write a method which imports this file into our database, into the normalized tables and relates the entries between each other. (For example: an address has a city_id which points to the correct city in the cities table)

Important: We are interesting in the logic and backend functionality. It is not necessary to write any frontend code or forms.

## Additional information

The Sepomex postal code file has the following information:
- d_codigo: Postal code
- d_asenta: Neighborhood (Colonia)
- D_mnpio: Municipality
- d_estado: State
- d_ciudad: City

You can ignore the other columns of the file.

* Please also note that some Mexican postal codes do have a leading zero, like 06100.
* The Sepomex download file contains many sheets. Please make sure to consider all sheets of the file in your import method.
* Even though this task is limited to importing Mexican postal codes, as we use the same postal codes table for all international postal codes, the postal_code column is a string, as some countries do not have numeric postal codes. (For example Canada)
* The same city name and the same neighborhood name can exists more than once in Mexico. Example: Neighborhood "Centro" can exist in different cities. In this case, we will have several entries neighborhood "Centro" in the table. Each one of course related to the correct city.
* The uniqueness of a neighborhood is defined by the neighborhood + the postal code and the country.
* The uniqueness of a city is defined by the city + the postal code and the country .
* The uniqueness of a postal code is defined by the postal code and the country.
* The uniqueness of a state is defined by the state and the country.
* The uniqueness of a municipality is defined by the municipality + the city and the country.
* The postal code and address information of a country rarely changes. After the initial load of the information, future updates will only change 1-3% of the information in the database. (Whereas the other 90-95% will already exist in the tables)
* Some countries literally manage hundreds of thousands, some even millions of adresses. The Mexican import file is not that big, but please consider that performance is essential. Your process should (theoretically) not only be working for the size of the Mexican import file, but also for files much bigger.

## Technical information

The import method should fill the following tables:

* neigborhoods --------> neighborhood
* postal_codes------> postal_code
* municipalities----> municipality
* cities------------> city
* states------------> state

You will have to create the according models, using scheme of the database. To restore/create the structure, you can run the following command:

``` rails db:schema:load ```

## Final words and what we expect

We will evaluate your code based on the following criteria:
* Code design and structure
* Code readability
* Query efficiency
* The efficiency and execution time of the method.

Please feel free to add any column, indexes, keys, constraints and checks you like to the database tables. The initial DB scheme we provide is only a basic structure to make your life easier. We do not want you to spend time on the basic things, but want you to do your programming magic on the advanced methods and logics. :)

Please also make sure your code will work well in both scenarios: 
1. The initial load of the information when the tables are empty.
2. The consecutive updates when a big part of the information will already exist in the database. (You need to think of the most efficient process to detect which data is unchanged, which has been updated, which is new and which does not exist in the import file anymore and hence needs to be deleted from the database) If done well, consecutive loads should be faster than the initial load.

Please feel free to contact us if you have any questions. We are also very happy to listen to your comments and feedback about this test task. If there are things you believe we can improve, please let us know. We are always open to any kind of feedback and suggestions. Honesty and a direct, good communication is a very important value in our company.

Thank you very much for taking the time to do this test. We appreciate your effort a lot and hope you will be joining our team very soon.