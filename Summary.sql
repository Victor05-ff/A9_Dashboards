/*
==========================================================================
A9 Dashboards – SQL Backend and Dashboard Project Summary & Architecture
==========================================================================

Project Overview:
-----------------
This project implements a SQL backend architecture and ASP.NET dashboard 
for monitoring machine uptime/downtime, reject reasons, and key KPIs 
from injection molding production lines.

The system uses a 30-second raw data feed, aggregates hourly KPIs, and 
provides dashboards refreshed in near real-time.

--------------------------------------------------------------------------

1. Database Tables:
-------------------
- dbo.A9_Lines
    Stores 4 production lines.

- dbo.A9_LineComponents
    Stores components linked to each line.

- dbo.A9_RawMachineData_Log
    Rolling 24-hour buffer of 30-second raw machine data.
    Includes counts, timestamps, downtime seconds, reject reasons.

- dbo.A9_Lot_Hourly
    Aggregated hourly KPIs per lot:
    Availability, Performance, Quality, OEE.

--------------------------------------------------------------------------

2. Stored Procedures:
---------------------
- dbo.sp_InsertSimulatedMachineData
    Generates realistic test data every 30 seconds.
    Lot number rotates every 3 hours.
    Yield: 50-80%; Runtime: 40-60% of planned time.
    Randomized downtime metrics.

- dbo.sp_AggregateLot_Hourly
    Aggregates raw data to hourly KPIs.
    UPSERTs into dbo.A9_Lot_Hourly.

- dbo.sp_ClearOldRawMachineData
    Cleans up raw data older than 24 hours

--------------------------------------------------------------------------

3. User-Defined Table-Valued Functions (TVFs):
----------------------------------------------
- dbo.ufn_ComponentDowntime_LastShift(@ComponentName NVARCHAR(100))
    Calculates downtime reasons over the last shift (12 hours).

- dbo.ufn_ComponentDowntime_Last4Hrs(@ComponentName NVARCHAR(100))
    Same as above, but scoped to last 4 hours.

--------------------------------------------------------------------------

4. ASP.NET Dashboard Backend:
------------------------------
- Populates dropdowns dynamically from database.
- Binds GridViews for last 4 hours and last shift downtime by reason.
- Supports filtering by component and downtime type.
- Color codes rows based on downtime type (Alarm=red, Wait=orange).
- Auto-refresh every 30 seconds with paging support.

--------------------------------------------------------------------------

5. Project Status:
-----------------
- SQL backend and procedures implemented and tested.
- Dashboard backend code completed.
- Ready to publish to GitHub for team collaboration.

==========================================================================

SQL Architecture & Data Flow:
-----------------------------

[ External Systems ]
       │
       │
       ▼
[ Data Generation & Input ]
       ├── Real Machine Data Feed (PLCs, SCADA, MES, IoT)
       └── Test Data Generator (sp_InsertSimulatedMachineData, scheduled)

       │
       ▼
[ Raw Data Storage ]
  ┌─────────────────────────────┐
  │  A9_RawMachineData_Log      │  <─ 30-sec raw data + downtime info
  └─────────────────────────────┘
       │
       ▼
[ Data Aggregation Layer ]
  ┌─────────────────────────────┐
  │  sp_AggregateLot_Hourly     │  <─ Aggregate raw to hourly KPIs
  └─────────────────────────────┘
       │
       ▼
[ Aggregated KPI Storage ]
  ┌─────────────────────────────┐
  │  A9_Lot_Hourly              │  <─ Hourly KPI data ready for dashboard
  └─────────────────────────────┘
       │
       ▼
[ Analytical Queries & UI Functions ]
  ┌─────────────────────────────────────────────┐
  │  ufn_ComponentDowntime_LastShift            │
  │  ufn_ComponentDowntime_Last4Hrs             │
  │  (Downtime summary by component)            │
  └─────────────────────────────────────────────┘
       │
       ▼
[ ASP.NET Dashboard Backend ]
  ┌─────────────────────────────────────────────┐
  │  Data binding, filtering, coloring, paging  │
  │  Auto refresh every 30 seconds              │
  └─────────────────────────────────────────────┘
       │
       ▼
[ User Dashboard Interface ]
  ┌─────────────────────────────────────────────┐
  │  Downtime reason grids for last 4 hrs &     │
  │  last shift with filtering by component     │
  └─────────────────────────────────────────────┘

==========================================================================
*/
