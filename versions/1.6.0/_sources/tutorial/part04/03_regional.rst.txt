======================
Extracting by location
======================

Up to this point, we have only looked at the summary data from each
*model run*. There is a lot more that can be explored, as ``metawards``
models the outbreak in every ward in the model (e.g. every electoral
ward in the UK).

Metadata about those wards is loaded into
:meth:`~metawards.Network.info` object, which is of class
:class:`~metawards.WardInfos`. This class can be queried to get
the index of wards according to their name, their official ID code,
or the local authority or region in which it belongs.

Searching using WardInfo
------------------------

For example, we can find all of the wards that match the name
"Clifton" using the below code. Open up ``ipython`` or a Jupyter
notebook and type;

.. code-block:: python

   >>> from metawards import Network, Parameters
   >>> params = Parameters.load()
   >>> params.set_input_files("2011Data")
   >>> params.set_disease("lurgy")
   >>> network = Network.build(params)

This has now built a network object that you can query, e.g.

.. code-block:: python

   >>> clifton = network.info.find("Clifton")
   >>> print(clifton)
   [154, 403, 829, 3612, 3662, 3670, 3703, 3766, 3974, 3975, 8134, 8327, 8328]
   >>> for ward in clifton:
   ...     print(network.info[ward])
   WardInfo(name='Clifton-with-Maidenway', alternate_names=['Clifton-with-Maidenway'], code='E05002101', alternate_codes=['E36000654'], authority='Torbay', authority_code='E06000027', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05003119', alternate_codes=['E36001870'], authority='Allerdale', authority_code='E07000026', region='', region_code='')
   WardInfo(name='Clifton and Bradley', alternate_names=['Clifton and Bradley'], code='E05003350', alternate_codes=['E36002100'], authority='Derbyshire Dales', authority_code='E07000035', region='', region_code='')
   WardInfo(name='Skelton, Rawcliffe and Clifton Without', alternate_names=['Skelton, Rawcliffe and Clifton Without'], code='E05001763', alternate_codes=['E36000299'], authority='York', authority_code='E06000014', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001980', alternate_codes=['E36000533'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Clifton East', alternate_names=['Clifton East'], code='E05001981', alternate_codes=['E36000534'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001747', alternate_codes=['E36000283'], authority='York', authority_code='E06000014', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001648', alternate_codes=['E36000184'], authority='Blackpool', authority_code='E06000009', region='', region_code='')
   WardInfo(name='Clifton North', alternate_names=['Clifton North'], code='E05001831', alternate_codes=['E36000367'], authority='Nottingham', authority_code='E06000018', region='', region_code='')
   WardInfo(name='Clifton South', alternate_names=['Clifton South'], code='E05001832', alternate_codes=['E36000368'], authority='Nottingham', authority_code='E06000018', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05005188', alternate_codes=['E36003801'], authority='Fylde', authority_code='E07000119', region='', region_code='')
   WardInfo(name='Cliftonville East', alternate_names=['Cliftonville East'], code='E05005087', alternate_codes=['E36003700'], authority='Thanet', authority_code='E07000114', region='', region_code='')
   WardInfo(name='Cliftonville West', alternate_names=['Cliftonville West'], code='E05005088', alternate_codes=['E36003701'], authority='Thanet', authority_code='E07000114', region='', region_code='')

This has returned all wards that have "Clifton" in the name. The search is
actually performed as a `regular expression <https://chryswoods.com/intermediate_python/regexp.html>`__,
and is case-insensitive. You can pass a regular expression string directly,
e.g. ```r"^(Clifton)$"``` would match "Clifton" at the beginning (```^```) and
end (```$```) of the string, i.e. it only matches wards that exactly
match "Clifton". Try this by typing;

.. code-block:: python

   >>> clifton = network.info.find(r"^(Clifton)$")
   >>> for ward in clifton:
   ...    print(network.info[ward])
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05003119', alternate_codes=['E36001870'], authority='Allerdale', authority_code='E07000026', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001980', alternate_codes=['E36000533'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001747', alternate_codes=['E36000283'], authority='York', authority_code='E06000014', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001648', alternate_codes=['E36000184'], authority='Blackpool', authority_code='E06000009', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05005188', alternate_codes=['E36003801'], authority='Fylde', authority_code='E07000119', region='', region_code='')

Searching by local authority
----------------------------

There are many "Clifton"s in the UK. We can limit to the "Clifton" in Bristol
by specifying the local authority. Again, this can be a regular expression,
although in this case just searching for "Bristol" will be enough.

.. code-block:: python

   >>> clifton = network.info.find(r"^(Clifton)$", authority="Bristol")
   >>> for ward in clifton:
   ...     print(ward)
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001980', alternate_codes=['E36000533'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')

.. note::
   In this case the dataset does not include regional data (the ```region```
   is empty). If regional data was available you could search by region
   using ```network.info.find("Clifton", region="South West")``.

This searching is very powerful. For example, we can now search for all
wards that are in the same local authority as "Clifton, Bristol", e.g.

.. code-block:: python

   >>> clifton = network.info.find(r"^(Clifton)$", authority="Bristol")[0]
   >>> clifton = newwork.info[clifton]
   >>> authority_code = clifton.authority_code
   >>> wards = network.info.find(authority=authority_code)
   >>> for ward in wards:
   ...     print(ward)
   WardInfo(name='Brislington West', alternate_names=['Brislington West'], code='E05001978', alternate_codes=['E36000531'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Cabot', alternate_names=['Cabot'], code='E05001979', alternate_codes=['E36000532'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Clifton', alternate_names=['Clifton'], code='E05001980', alternate_codes=['E36000533'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Clifton East', alternate_names=['Clifton East'], code='E05001981', alternate_codes=['E36000534'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Cotham', alternate_names=['Cotham'], code='E05001982', alternate_codes=['E36000535'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Easton', alternate_names=['Easton'], code='E05001983', alternate_codes=['E36000536'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Eastville', alternate_names=['Eastville'], code='E05001984', alternate_codes=['E36000537'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Filwood', alternate_names=['Filwood'], code='E05001985', alternate_codes=['E36000538'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Frome Vale', alternate_names=['Frome Vale'], code='E05001986', alternate_codes=['E36000539'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Hartcliffe', alternate_names=['Hartcliffe'], code='E05001987', alternate_codes=['E36000540'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Henbury', alternate_names=['Henbury'], code='E05001988', alternate_codes=['E36000541'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Hengrove', alternate_names=['Hengrove'], code='E05001989', alternate_codes=['E36000542'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Henleaze', alternate_names=['Henleaze'], code='E05001990', alternate_codes=['E36000543'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Hillfields', alternate_names=['Hillfields'], code='E05001991', alternate_codes=['E36000544'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Horfield', alternate_names=['Horfield'], code='E05001992', alternate_codes=['E36000545'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Kingsweston', alternate_names=['Kingsweston'], code='E05001993', alternate_codes=['E36000546'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Ashley', alternate_names=['Ashley'], code='E05001972', alternate_codes=['E36000525'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Avonmouth', alternate_names=['Avonmouth'], code='E05001973', alternate_codes=['E36000526'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Bedminster', alternate_names=['Bedminster'], code='E05001974', alternate_codes=['E36000527'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Bishopston', alternate_names=['Bishopston'], code='E05001975', alternate_codes=['E36000528'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Bishopsworth', alternate_names=['Bishopsworth'], code='E05001976', alternate_codes=['E36000529'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Brislington East', alternate_names=['Brislington East'], code='E05001977', alternate_codes=['E36000530'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Knowle', alternate_names=['Knowle'], code='E05001994', alternate_codes=['E36000547'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Lawrence Hill', alternate_names=['Lawrence Hill'], code='E05001995', alternate_codes=['E36000548'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Lockleaze', alternate_names=['Lockleaze'], code='E05001996', alternate_codes=['E36000549'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Redland', alternate_names=['Redland'], code='E05001997', alternate_codes=['E36000550'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='St George East', alternate_names=['St George East'], code='E05001998', alternate_codes=['E36000553'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='St George West', alternate_names=['St George West'], code='E05001999', alternate_codes=['E36000554'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Southmead', alternate_names=['Southmead'], code='E05002000', alternate_codes=['E36000551'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Southville', alternate_names=['Southville'], code='E05002001', alternate_codes=['E36000552'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Stockwood', alternate_names=['Stockwood'], code='E05002002', alternate_codes=['E36000555'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Stoke Bishop', alternate_names=['Stoke Bishop'], code='E05002003', alternate_codes=['E36000556'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Westbury-on-Trym', alternate_names=['Westbury-on-Trym'], code='E05002004', alternate_codes=['E36000557'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Whitchurch Park', alternate_names=['Whitchurch Park'], code='E05002005', alternate_codes=['E36000558'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')
   WardInfo(name='Windmill Hill', alternate_names=['Windmill Hill'], code='E05002006', alternate_codes=['E36000559'], authority='Bristol, City of', authority_code='E06000023', region='', region_code='')

.. note::

   It is true that we could have achieved this by just searching for
   Bristol alone. However, this method of searching for ward+authority
   is more robust against multiple authorities having similar names.
   For example, searching for the authority "Newcastle" returns
   both "Newcastle upon Tyne" and "Newcastle-under-Lyme".

Using location in an extractor
------------------------------

We can use the above search to track the total number of infections in each
of the wards in Bristol. Create a new python file called ``location.py``
and copy in the below;

.. code-block:: python

    matched_wards = None
    headers = []

    def output_location(network, population, workspace, output_dir, **kwargs):
        ward = "clifton"
        authority = "bristol"

        global matched_wards, headers

        if matched_wards is None:
            # This is performed only once, when this function is first called
            ward = network.info.find(name=ward, authority=authority)[0]
            ward = network.info[ward]
            authority_code = ward.authority_code
            matched_wards = network.info.find(authority=authority_code)

            headers = []
            headers.append("day")

            for ward in matched_wards:
                headers.append(f"'{network.info[ward].name}'")

        # open the file called "authority.dat", e.g. "bristol.dat"
        # Note we are using comma separators and have put the ward
        # names in single quotes to make the output easier to parse
        locfile = output_dir.open(f"{authority}.dat", headers=headers, sep=",")

        locfile.write(str(population.day))

        for ward in matched_wards:
            total = workspace.total_inf_ward[ward]
            locfile.write("," + str(total))

        locfile.write("\n")

    def extract_location(**kwargs):
        from metawards.extractors import extract_default

        return extract_default(**kwargs) + [output_location]

Save the file and run ``metawards`` using this extractor via

.. code-block:: bash

   metawards --extractor location

You should see that a new output file called ``bristol.dat.bz2`` was
created. Loading this up into pandas should show;

.. code-block:: python

   >>> import pandas as pd
   >>> df = pd.read_csv("output/bristol.dat.bz2", index_col="day")
   >>> print(df)
         'Brislington West'  'Cabot'  ...  'Whitchurch Park'  'Windmill Hill'
    day                               ...
    0                     0        0  ...                  0                0
    1                     0        0  ...                  0                0
    2                     0        0  ...                  0                0
    3                     0        0  ...                  0                0
    4                     0        0  ...                  0                0

    [5 rows x 35 columns]

