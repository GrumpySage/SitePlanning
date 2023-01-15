# Case: Site Planning
- by Jonas Neubert Pedersen

## Disclaimers
I do not have much experience with production planning, so some of my assumptions, terms and such may not be quite correct.
Listen, do not read. 
Ask if there are any questions.

## Assumptions
Especially when dealing with a solution for an end user, I would much prefer to communicate with them so a solution can be created that caters to their needs and wishes.
I made the following assumptions:
- The end user wants to get an easy overview of the Stock Transport Orders to see whether a material is available on the date and in the quantity needed.
- It would be good to see if a material is produced very close to being needed (higher risk if there is a delay) or is being produced too far ahead of schedule (as this will take up warehouse space).
- Quantity of STO can be greater than PO.

## Overview of solution
![Object Diagram](https://user-images.githubusercontent.com/31987339/212538158-e8ad169c-4188-49bb-bc94-985bb125abe3.png)


##### YCL_SUPPLY_FORECAST
Main class, should be scheduled hourly.
Gets data from APIs using YCL_SP_DATA_PROVIDER.

##### YCL_SP_DATA_PROVIDER
Gets PO and STO data from APIs.

##### YSP_PROD_ORDER
Database table, holds PO information pulled from API.

##### YSP_STO
Database table, holds STO information pulled from API.

##### YSP_SUPPLY_FORECAST_JOIN
CDS view that joins database tables YSP_PROD_ORDER and YSP_STO. Also calculates criticality color for overview.

##### YSP_SUPPLY_FORECAST_OVERVIEW
CDS view, gets data through YSP_SUPPLY_FORECAST_JOIN, handles design of the UI.

##### YSP_SUP_FORECAST_OVERVIEW_SD
Service Definition of Overview.

##### YSP_SUP_FORECAST_OVERVIEW_SB
Service Binding of Overview for Fiori app.

##### YSP_WEB_SF_OVERVIEW_SB
Service Binding of Overview for external consumption.

### Overview page for PO/STO
![image](https://user-images.githubusercontent.com/31987339/212562649-b4f7d542-7468-4479-bd1a-bcced8c05066.png)

### Detail page for PO/STO
![image](https://user-images.githubusercontent.com/31987339/212562677-a6d2c835-e0eb-459f-b0dd-3a125c06b82f.png)

---

##### YSP_SUP_FORECAST
Database table holding the summation of POs and STOs for each material/plant combination.

##### YSP_SUPPLY_FORECAST_SUM
CDS view, gets data from YSP_SUP_FORECAST, handles design of the UI.

##### YSP_SUPPLY_FORECAST_SUM_SD
Service Definition of Sum View.

##### YSP_SUPPLY_FORECAST_SUM_SB
Service Binding of Sum View for Fiori app.

##### YSP_WEB_SF_SUM_SB
Service Binding of Sum View for external consumption.

### Overview page summed PO/STOs
![image](https://user-images.githubusercontent.com/31987339/212562619-1d51963a-1cc7-43ca-b307-3d21a7b48a77.png)


### Live demo of user facing apps
- Added that "Go" button is pressed automatically in the Fiori app.

## Design decisions
- If job receives data from endpoints, it deletes the old data, since the API is the principal holder of data. We don't want to duplicate data as much as possible.


## Limitations and considerations
- We might get data from one API, but not the other. In such a case there is no longer a 1-to-1 link between order numbers (which the application assumes right now). In addition, it might not be the case in a live environment. Solution could be to match on material instead of order number.
- Currently there is not a lot of validation of the data. How much we want to implement depends how much we trust the sender. 
  - Could compare the PO and STO lists to ensure they are similar.
  - Could check for incorrect data (for example quantity of 0).
- Error handling is implemented, but I do not know how errors are caught within the greater system, so currently they are just being output to the console. How would I as the maintainer of the application be notified that something is failing?
- JSON serialization does not complain if the JSON does not match the ABAP structure. If the JSON changes, we'd have to change the code on our end too.
  - With actual endpoints, I would have set up Service Consumers using the metadata, which might also assist with the JSON serialization. Instead I opted to make a simpler class.
- Job scheduling is not set up, depends on the greater system.
- No authentication is set up for calls to the API.
- Could not add Fiori app in SAP HANA, did it in BAS and connected them.
- I went back and forth on creating a new class for handling API calls. In the end I decided to make one that could work to handle API calls to all kinds of external services across Site Planning. How specialized the class should be (and whether it should even exist) depends on the greater solution(s), current and future, within this area.


## Further development
- Sorting is not implemented, for example push to the top either orders with the closest requirement date or the orders that have the largest discrepancy.
- Users being in charge of certain plants, only being shown what is relevant to them.
- See if supply greatly outweighs demand.
- Unit of measure on quantity.
- Additional unit tests.
- There might be several plants that want the same material and/or several production orders for a single material. Could look into grouping this data to give an easier overview that you can then drill down into.
- Certain information, such as URLs for APIs and authentication details should come from a customizing table rather than being hardcoded.
