a.

db.borders.find({},{'_id':0,'country1.name':1}).sort({length:-1}).limit(1)


24 ms -> 0.024 sec
----------------------------------------------------------------------

c.

db.economy.find( {

 $expr: { 

 $and:[
 	{$gt: [ "$agriculture" , "$service" ]},
 	{$gt: [ "$agriculture" , "$inflation" ]},
 	{$gt: [ "$agriculture" , "$unemployment" ]},
 	{$gt: [ "$agriculture" , "$industry" ]}
 ],

 

  } 
} ,
{_id:0,'country.name':1, 'agriculture':1, 
'gdp':1,'inflation':1}
)

4 ms -> 0.004 sec
----------------------------------------------------------------------

f.

db.economy.aggregate([
{"$match": {
"gdp": {$exists: true,
"$ne": ''}
}},


{"$lookup": {
"from": "population",
"localField": "country",
"foreignField": "country_code",
"as": "pop"
}},     

{ "$project": {
    "_id": 0,
    "gdp": 1,
    "country.name":1,
    "pop.infant_mortality":1
}},              


{$sort: {"gdp": -1}},
{$limit: 10}
])

80ms -> 0.080s

----------------------------------------------------------------------

b.

db.city.aggregate([

        {
        $match:{
            "population": {"$ne": ''}
        }
        },

        {
       $group:
         {
           _id: "$country.code",
           max_pop: { $max: "$population"}
         }
        },
        {$lookup: {
        "from": "city",
        "let": {"cid": "$_id",
                "mp": "$max_pop"},
        pipeline: [
          {
            "$match": {
              "$expr": {
                $and: [
                        {
                           $eq: [
                              "$$cid",
                              "$country.code"
                           ]
                        },
                        {
                           $eq: [
                              "$$mp",
                              "$population"
                           ]
                        }
                     ]  
              },
            },
          },
        ],
        as: "details"
      }}, 

        { "$project": {
        "_id": 0,
        "details.country.name": 1,
        "details.name":1
        }} 

    ])


    983ms -> 0.983 s


 ________________________________________________________________________


d.

db.ethnicgroup.aggregate([


      {$group:
         {
           "_id": "$country_code.code",
           "name": { $last: "$country_code.name" },
           "count":{$sum:1},
           "mx": { "$max": "$ethnic_group_percentage"}
         }
        },
        {$sort:{"count":-1}}



    ])

23 ms -> 0.023s

________________________________________________________________________

g.


db.religion.aggregate([

        {$group:
         {
           "_id": "$country.code",
           "cname": { $last: "$country.name" },
           "count":{$sum:1}
         }
        },
        {$sort: {'count':-1}},
        {$limit:1},
        {$lookup: {
        "from": "religion",
        "let": {"cid": "$_id",
                "cn": "$count"},
        pipeline: [
          {
            "$match": {
              "$expr": {
                   $eq: [
                      "$$cid",
                      "$country.code"
                   ]
                         
 
              },
            },
          },
        ],
        as: "details"
      }},
      
      {$project:{
        "_id":0,
        "count":1,
        "details.country.name":1,
        "details.name":1,


      }},


    ])

15 ms -> 0.015s
________________________________________________________________________

h. 


db.economy.aggregate([

        {
        $match:{
            "gdp": {"$ne": ''}
        }
        },

        {$sort: {"gdp":-1}},
        {$limit:100},
        {$lookup: {
        "from": "ismember",
        "let": {"cid": "$country.code"},
        pipeline: [
          {
            "$match": {
              "$expr": {
                $and: [
                        {
                           $eq: [
                              "$$cid",
                              "$country.code"
                           ]
                        },
                        {
                           $eq: [
                              "$organization.name",
                              "Commonwealth"
                           ]
                        }
                     ]  
              },
            },
          },
        ],
        as: "details"
      }},
      {
        $match:{
            "details": {"$ne": []}
        }
        } 


    ]).toArray().length/100

1261ms -> 1.261 s


________________________________________________________________________

i.

db.country_continent.aggregate([

        {$project:{
            "code": "$code",
            "pop_dens": { $divide: [ "$code.population", "$code.area" ] },
            "encompasses_continent": "$encompasses_continent"
        }},

        {$group:{
            "_id": "$encompasses_continent.encompasses_continent",
            "mx": {"$max": "$pop_dens"}
        }},

        {$lookup: {
        "from": "country_continent",
        "let": {"cid": "$_id",
                "mxx": "$mx"},
        pipeline: [
          {
            "$match": {
              "$expr": {
                $and: [
                        {
                           $eq: [
                              "$$cid",
                              "$encompasses_continent.encompasses_continent"
                           ]
                        },
                        {
                           $eq: [
                              "$$mxx",
                              { $divide: [ "$code.population", "$code.area" ] }
                           ]
                        }
                     ]  
              },
            },
          },
        ],
        as: "details"
      }},
      {$project:{
            "_id":1,
            "mx":1,
            "details.code.name":1
      }}



    ])



    20ms -> 0.020 s

________________________________________________________________________

j.


db.airport.aggregate([
          {
            "$match": {
              "$expr": {
                $and: [
                        {
                           $eq: [
                              "$city.name",
                              "$country_code.capital"
                           ]
                        },
                        {
                           $eq: [
                              "$airport_province.name",
                              "$country_code.province"
                           ]
                        }
                     ]  
              },
            },
          },

          {
          $group:{
            "_id":"$country_code.code",
            "count":{$sum:1}
          }
          },
          {$lookup: {
        "from": "country",
        "let": {"cid": "$_id",
                "cn": "$count"},
        pipeline: [
          {
            "$match": {
              "$expr": {
               $and: [
                        {
                           $eq: [
                              "$$cid",
                              "$code"
                           ]
                        },
                        {
                           $gt: [
                              "$$cn",
                              1
                           ]
                        }
                     ] 
 
              },
            },
          },
        ],
        as: "details"
      }},
      {
        $match:{
            "details": {"$ne": []}
        }
      },
      {$project:{
            "_id":0,
            "details.name":1,
            "details.capital":1,
            "count":1
      }}

    ])



    94ms -> 0.094 s

________________________________________________________________________



e.

db.ethnicgroup.aggregate([

        {$group:{
            "_id": "$country_code.code",
            "count": {$sum:1}
        }},
        {$lookup: {
        "from": "language",
        "let": {"cid": "$_id",
                "cn": "$count"},
        pipeline: [
          {
            "$match": {
              "$expr": {
                   $eq: [
                      "$$cid",
                      "$country.code"
                   ]
                         
 
              },
            },
          },
        ],
        as: "details"
      }},
      {$addFields: {
              "ct": {"$size":"$details"}
           }},
       {$match:{
            "$expr": {
                $eq: [
                  "$ct",
                  "$count"
                ]

            }   
       }},

      {$project:{
        "_id":0,
        "count":1,
        "details.country.name":1,
        "details.language":1,
        ct:1


      }},

    ]).toArray().length

494ms -> 0.494s


