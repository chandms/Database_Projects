db.province.find({

$and: [
      { "country.code": "IRQ" },
       { "name": "Basrah"} 
   ]

   })



db.province.find({"country.code":"IRQ"},{"country.code":1,"country._id":0})


db.province.find({"country.code":"IRQ"},{"country.code":1})



db.borders.find({

   })


db.economy.find({

	$match:{
		$expr:{
			$and: [
				{$gt:["$agriculture", "$service"]},
				{$gt:["$agriculture", "$inflation"]}

			]
		}
	}

	})
	$and: [
       { '$agriculture': { $gt: 'service' } },
       { 'agriculture': { $gt: 'inflation' } },
       { 'agriculture': { $gt: 'industry' } },
       { 'agriculture': { $gt: 'unemployment' } },
   	]

	})




db.economy.aggregate({
	$match:{$expr:$gt:["$ag{riculture", "$service"]}}
	})


db.myCollection.find({$expr: {$gt: ["$agriculture", "$a2.a"] } });

db.economy.find({$where: "this.agriculture > this.service" and 
	"this.agriculture > this.unemployment"});


db.economy.find({
	$where:{
	  $and:[
	  	{"this.agriculture > this.service"},
	  	{"this.agriculture > this.inflation"}
	  ]
	}
	})


db.economy.find({
  $and: [
    {
      "$agriculture": {
        $gt: "$service"
      }
    },
    {
      "$agriculture": {
        $gt: "$inflation"
      }
    }
  ]
})




db.economy.find( {

 $expr: { 

 $gt: [ "$agriculture" , "$service" ],



  } 
} )


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


db.economy.aggregate([
{$lookup:{
from: "population",
localField: "country",
foreignField: "country_code",
as: "population"}},
{$sort: {"gdp": -1}},
{$limit: 10},

{ "$project": {
        "_id": 0,
        "gdp": 1,
        "population.infant_mortality": 1,
    }},

]
)

pipeline: [
      { $match: {{ "$gdp" :{ "$ne" : null }} }}
    ]


db.economy.aggregate([
{$lookup:{from: "population",localField: "country",foreignField: "country_code",as: "population"}},
{$sort: {"gdp": -1}},
{$limit: 10},
{ "$project": {
        "_id": 0,
        "gdp": 1,
        "population.infant_mortality": 1
    }},

]
)

db.economy.aggregate([
					{"$match": {
                    "gdp": {"$ne": null}
                    }},
                    {$sort: {"gdp": -1}},
				    {$limit: 10}
                    ])


db.economy.aggregate([
  {
    $project: {
      values: {
        $filter: {
          input: "$gdp",
          as: "d",
          cond: {
            $ne: [
              "$d",
              null
            ]
          }
        }
      }
    }
  },
  {
    $match: {
      "gdp": {
        $ne: []
      }
    }
  },
  {
    "$sort": {
      "gdp": -1
    }
  },
  {
  $limit:10
  }
]);

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



db.city.aggregate([
	{"$match": {
	"population": {$exists: true,
	"$ne": ''}
	}},

	{"$lookup": {
	"from": "country",
	"localField": "country.code",
	"foreignField": "code",
	"as": "cc"
	}}, 

	{ "$project": {
	"_id": 0,
    "country.name": 1,
    "name":1
	}}
])

db.city.aggregate([{$lookup: {
    "from": "population",
    "let": {"cid": "$country"},
    pipeline: [
      {
        "$match": {
          "$expr": {
            "$eq": ["$cid", "$country.code"],  
          },
        },
      },
    ],
    as: "details"
  }}])



db.economy.aggregate([
					{"$lookup": {
                    "from": "population",
                    "localField": "country",
                    "foreignField": "country.code",
                    "as": "population"
                    }},                   
                    { "$project": {
        				"_id": 0,
				        "gdp": 1,
				        "country":1
				    }},
                    
				    {$sort: {"gdp": -1}},
				    {$limit: 10}


                   

                    ])


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



 db.city.aggregate([
    { 
        "$match": {
            "population": { 
                "$exists": true, 
                "$ne": '' 
            }
        }    
    },
    { 
        "$group": {
            "_id": "$country.code",
            max_pop: { $max: "$population"}
        }   
    }        
]);






db.ethnicgroup.aggregate([
	{
       $group:
         {
           _id: "$country_code.code",
           count:{$sum:1}
         }
     	}
	])
db.language.aggregate([
	{
       $group:
         {
           _id: "$country.code",
           count:{$sum:1}
         }
     	}
	])

db.ethnicgroup.aggregate([
		{$lookup: {
	    "from": "language",
	    "let": {"cid": "$country_code.code"},
	    pipeline: [
	      {"$match": {
	          "$expr": {
                        
                       $eq: [
                          "$$cid",
                          "$country.code"
                       ]
	          }
	        }
	      }
	    ],
	    as: "details"
	  }},
	  { "$project": {
		"_id": 0,
		"country_code.code":1,
	    "details.country.name": 1,
	    "details.language":1,
	    "ethnic_group_name":1
		}},
		{ 
        "$group": {
            "_id": "$country_code.code",
            count:{$sum:1}
        }   
    	}

	])

db.ethnicgroup.aggregate([


		{
       $group:
         {
           _id: "$country_code.code",
           eg: { $count:{$sum:1}
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


db.ethnicgroup.aggregate([


      {$group:
         {
           "_id": "$country_code.code",
           "name": { $last: "$country_code.name" },
           "count":{$sum:1},
           "mx": { "$max": "$ethnic_group_percentage"}
         }
     	}



	])


db.religion.aggregate([

		{$group:
         {
           "_id": "$country.code",
           "cname": { $last: "$country.name" },
           "count":{$sum:1}
         }
     	},
     	{$sort: {'count':-1}},
     	{$limit:1}

	])


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

	])


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

