      # Data Dictionary for Gold Layer
     ---
     ## Overview

      The Gold Layaer is the business-level representation, structured to support analytical and reportin use cases. it consoists of dimension 
      tables and fact tables for specific business metrics.
     ---
     ## 1. gold.dim_customers

          - **Purpose:** Stores customer details enriched with demographic and geographic data.
          - **Columns:**

          |Column Name  | Data Type | Description |
          |customer_key | INT       | Surrogate key uniquely identifing each customer record in the dimension table.
          |customer_id  | INT       | Unique numerical identifier assigned to each customer.
      
      
