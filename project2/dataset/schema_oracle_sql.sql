
  CREATE TABLE country(
  	name VARCHAR(200),
  	code VARCHAR(50) PRIMARY KEY,
  	capital VARCHAR(200),
  	province VARCHAR(200),
  	area NUMBER,
  	population NUMBER

  );


  CREATE TABLE continent(
  	encompasses_continent VARCHAR(200) PRIMARY KEY,
  	continent_area NUMBER
  );

  CREATE TABLE country_continent(

  	code VARCHAR(50),
  	encompasses_continent VARCHAR(200),
  	encompass_percentage NUMBER,
  	CONSTRAINT pk_country_continent
      PRIMARY KEY( code, encompasses_continent ),

    CONSTRAINT fk_country_continet_country
      FOREIGN KEY( code )
      REFERENCES country( code ) 
      ON DELETE CASCADE ,

    CONSTRAINT fk_country_continent_continent
      FOREIGN KEY ( encompasses_continent )
      REFERENCES continent( encompasses_continent )
      ON DELETE CASCADE,

    Constraint country_cons CHECK (encompass_percentage>=0 
    	and encompass_percentage<=100 )


  );


 CREATE TABLE BORDERS
  (

  	country1 VARCHAR(50),
  	country2 VARCHAR(50),
  	length NUMBER,
  	CONSTRAINT pk_borders
      PRIMARY KEY( country1, country2 ),
    CONSTRAINT fk_border_country1
      FOREIGN KEY( country1 )
      REFERENCES country( code ) 
      ON DELETE CASCADE ,
    CONSTRAINT fk_border_country2
      FOREIGN KEY( country2 )
      REFERENCES country( code ) 
      ON DELETE CASCADE

  );

  CREATE TABLE PROVINCE(

  	 name VARCHAR(200),
  	 country VARCHAR(50),
  	 population NUMBER,
  	 area NUMBER,
  	 capital VARCHAR(200),
  	 capprov VARCHAR(200),

  	 CONSTRAINT pk_province
  	 	PRIMARY KEY (name, country),
  	 CONSTRAINT fk_province_country
  	 	FOREIGN KEY (country)
  	 	REFERENCES country(code)
  	 	ON DELETE CASCADE

  	);



CREATE TABLE CITY(

	name VARCHAR(200),
	country VARCHAR(50),
	province VARCHAR(200),
	population NUMBER,
	elevation NUMBER,
	latitude NUMBER,
	longitude NUMBER,

	CONSTRAINT pk_city
  	 	PRIMARY KEY (name, country, province),

  	CONSTRAINT pk_city_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT pk_city_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE,

  	Constraint city_cons CHECK (latitude>=-90 
  		and latitude<=90 and longitude>=-180 and longitude<=180)


);

CREATE TABLE CITYLOCALNAME(

	city VARCHAR(200),
	country VARCHAR(50),
	province VARCHAR(200),
	localname VARCHAR(200),
	CONSTRAINT pk_city_localname
  	 	PRIMARY KEY (city, country, province),

  	CONSTRAINT fk_city_localname_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_city_localname_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE,


  	CONSTRAINT fk_city_localname_city
  		FOREIGN KEY (city, province, country)
  		REFERENCES city(name, province, country)
  		ON DELETE CASCADE


);

CREATE TABLE CITYOTHERNAME(

	city VARCHAR(200),
	country VARCHAR(50),
	province VARCHAR(200),
	othername VARCHAR(200),
	CONSTRAINT pk_city_othername
  	 	PRIMARY KEY (city, country, province, othername),

  	CONSTRAINT fk_city_othername_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_city_othername_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE,


  	CONSTRAINT fk_city_othername_city
  		FOREIGN KEY (city, province, country)
  		REFERENCES city(name, province, country)
  		ON DELETE CASCADE


);

CREATE TABLE CITYPOPULATIONS(

	city VARCHAR(200),
	country VARCHAR(50),
	province VARCHAR(200),
	population NUMBER,
	year NUMBER,
	CONSTRAINT pk_city_populations
  	 	PRIMARY KEY (city, country, province, year),

  	CONSTRAINT fk_city_populations_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_city_populations_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE,


  	CONSTRAINT fk_city_populations_city
  		FOREIGN KEY (city, province, country)
  		REFERENCES city(name, province, country)
  		ON DELETE CASCADE


);

CREATE TABLE countryotherlocalname(

	country VARCHAR(50) PRIMARY KEY,
	othername VARCHAR(200),
	localname VARCHAR(200),

  	CONSTRAINT fk_countryotherlocalname_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE


);

CREATE TABLE countrypopulations(

	country VARCHAR(50),
	population NUMBER,
	year NUMBER,

	CONSTRAINT pk_countrypopulations
  	 	PRIMARY KEY (country, year),

  	CONSTRAINT fk_countrypopulations_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE


);


CREATE TABLE provincelocalname(
	
	province VARCHAR(200),
	country VARCHAR(50),
	localname VARCHAR(200),

	CONSTRAINT pk_provincelocalname
  	 	PRIMARY KEY (province, country),

  	CONSTRAINT fk_provincelocalname_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_provincelocalname_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE


);

CREATE TABLE provinceothername(
	
	province VARCHAR(200),
	country VARCHAR(50),
	othername VARCHAR(200),

	CONSTRAINT pk_provinceothername
  	 	PRIMARY KEY (province, country, othername),

  	CONSTRAINT fk_provinceothername_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_provinceothername_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE


);

CREATE TABLE provincepopulation(
	
	province VARCHAR(200),
	country VARCHAR(50),
	year NUMBER,
	population NUMBER,

	CONSTRAINT pk_provincpopulation
  	 	PRIMARY KEY (province, country, year),

  	CONSTRAINT fk_provincpopulation_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_provincpopulation_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE


);

CREATE TABLE religion(

	country VARCHAR(50),
	name VARCHAR(200),
	percentage NUMBER,

	CONSTRAINT pk_religion
		PRIMARY KEY (country, name),

  	CONSTRAINT fk_religion_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	Constraint rel_cons CHECK (percentage>=0 and percentage<=100 )


);

CREATE TABLE population(

	country_code VARCHAR(50) PRIMARY KEY,
	country_province VARCHAR(200),
	population_growth NUMBER,
	infant_mortality NUMBER,

  	CONSTRAINT fk_population_country
  		FOREIGN KEY (country_code)
  		REFERENCES country(code)
  		ON DELETE CASCADE


);

CREATE TABLE politics(

	country VARCHAR(50) PRIMARY KEY,
	independence VARCHAR(200),
	wasdependent VARCHAR(200),
	dependent VARCHAR(200),
	government VARCHAR(200),

  	CONSTRAINT fk_politics_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE


);

CREATE TABLE organization(

	abbreviation VARCHAR(200) PRIMARY KEY,
	name VARCHAR(200),
	city VARCHAR(200),
	country VARCHAR(200),
	province VARCHAR(200),
	established DATE,

	CONSTRAINT fk_organization_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_organization_city
  		FOREIGN KEY (city, province, country)
  		REFERENCES city(name, province, country)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_organization_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE



);



CREATE TABLE locatedon(

	city VARCHAR(200),
	province VARCHAR(200),
	country VARCHAR(50),
	island VARCHAR(200),

	CONSTRAINT pk_locatedon
		PRIMARY KEY (city, province, country, island),

	CONSTRAINT fk_locatedon_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_locatedon_city
  		FOREIGN KEY (city, province, country)
  		REFERENCES city(name, province, country)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_locatedon_province
  		FOREIGN KEY (province, country)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE



);

CREATE TABLE language(

	
	country VARCHAR(50),
	language VARCHAR(200),
	percentage NUMBER,

	CONSTRAINT pk_language
		PRIMARY KEY (country, language),

	CONSTRAINT fk_language_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	Constraint lang_cons CHECK (percentage>=0 and percentage<=100 )



);


CREATE TABLE ismember(

	
	country VARCHAR(50),
	organization VARCHAR(200),
	type VARCHAR(200),

	CONSTRAINT pk_ismember
		PRIMARY KEY (country, organization),

	CONSTRAINT fk_ismember_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE



);

CREATE TABLE ethnicgroup(

	
	country_code VARCHAR(50),
	ethnic_group_name VARCHAR(200),
	ethnic_group_percentage NUMBER,

	CONSTRAINT pk_ethnicgroup
		PRIMARY KEY (country_code, ethnic_group_name),

	CONSTRAINT fk_ethnicgroup_country
  		FOREIGN KEY (country_code)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	Constraint ethnic_cons CHECK (ethnic_group_percentage>=0 
  		and ethnic_group_percentage<=100 )



);

CREATE TABLE economy(

	
	country VARCHAR(50) PRIMARY KEY,
	gdp NUMBER,
	agriculture NUMBER,
	service NUMBER,
	industry NUMBER,
	inflation NUMBER,
	unemployment NUMBER,

	CONSTRAINT fk_economy_country
  		FOREIGN KEY (country)
  		REFERENCES country(code)
  		ON DELETE CASCADE



);


CREATE TABLE airport(

	
	iatacode VARCHAR(50) PRIMARY KEY,
	name VARCHAR(200),
	country_code VARCHAR(50),
	city VARCHAR(200),
	airport_province VARCHAR(200),
	island VARCHAR(200),
	latitude NUMBER,
	longitude NUMBER,
	elevation NUMBER,
	gmtoffset NUMBER,

	CONSTRAINT fk_airport_country
  		FOREIGN KEY (country_code)
  		REFERENCES country(code)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_airport_province
  		FOREIGN KEY (airport_province, country_code)
  		REFERENCES province(name, country)
  		ON DELETE CASCADE,

  	CONSTRAINT fk_airport_city
  		FOREIGN KEY (airport_province, country_code, city )
  		REFERENCES city(province, country, name)
  		ON DELETE CASCADE,

  	Constraint airport_cons CHECK (latitude>=-90 and latitude<=90 
  		and longitude>=-180 and longitude<=180 and gmtoffset>=-12 and gmtoffset<=14)


);
################################





 


