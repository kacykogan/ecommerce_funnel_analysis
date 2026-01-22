# Ecommerce Funnel Analysis Project

[**Interactive Tableau Dashboard** ](https://public.tableau.com/views/EcommerceFunnelProject_17688637575050/Dashboard1?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

## **Overview**

This project analyzes an e-commerce conversion funnel using Google Analytics 4 (GA4) sample data to understand how users progress from product view through purchase. The analysis focuses on funnel drop-offs, conversion rates, and differences in performance by device type as well as traffic source. Results are used to identify opportunities to optimize early funnel engagement and increase overall conversions.


### **Business Questions**

• How do users progress through the e-commerce funnel from View Item to Purchase?

• How do device types influence conversion rates?

• Which traffic sources drive the highest-intent users?

• Where are the largest opportunities to optimize the funnel?


### **Data**

•	Source: Google Analytics 4 BigQuery Sample Ecommerce Dataset

•	Timeframe: November 2020 – January 2021

•	Granularity: User-level events

•	Key Fields Used:
  - user_pseudo_id – unique user identifier
  - event_name – GA4 events (view_item, add_to_cart, begin_checkout, purchase)
  - event_timestamp – timestamp of each event
  - device.category – desktop, mobile, tablet
  - traffic_source.source and traffic_source.medium – first-touch attribution


### **Methodology**

1.	**Data Cleaning & Preparation**
	
    o	Extracted GA4 events related to the funnel

    o	Assigned one device and one traffic source per user based on first interaction

    o	Cleaned traffic source labels for clarity (e.g., (direct)/(none) to Direct, Other/organic to Organic Search (Other))
  
2.	**Funnel Construction**
	
    o	Defined a strict, ordered funnel from View Item to Purchase

    o	Ensured step dependency: users counted at a step only if they completed all previous steps

    o	Deduplicated users to avoid double counting

3.	**Analysis**

    o	Calculated step-level users by device and traffic source

    o	Calculated conversion rates:

    o	Conversion Rate = Users at Purchase ÷ Users at View Item
  
    o	Annotated anomalies such as high conversion rates in the Unknown traffic source category

4.	**Visualization**
	
    o	Created an interactive Tableau dashboard showing:
  	  - Funnel step users by device and traffic source
      - Conversion rates by device and traffic source
      - Insights and annotations for unusual data (Unknown traffic source)
      - Designed dashboard for clarity and business storytelling
        



### **Skills Demonstrated:**

This project highlights the following technical and analytical skills:

•	SQL (BigQuery) – Data extraction, cleaning, CTE, joins, and user-level funnel construction

•	Data cleaning and segmentation (device, traffic source)

•	Tableau – Interactive dashboard creation and annotation


### **Key Insights**

•	Device: Desktop drives the most traffic, but mobile users convert slightly better despite lower volume.

<img width="1830" height="451" alt="Funnel Step Users By Device Chart" src="https://github.com/user-attachments/assets/6be2f887-cc6b-4db0-86f3-e21f9a2d6d79" />

•	Traffic Source: Referral traffic and paid search users exhibit higher conversion rates. The Unknown traffic source shows high conversion likely due to returning users and attribution gaps.


<img width="1829" height="428" alt="Conversion Rates By Traffic Source" src="https://github.com/user-attachments/assets/7bb4e045-698b-4007-b9ff-69f1282f7d50" />



•	Funnel Drop-Off: The largest drop-off occurs between View Item to Add to Cart, highlighting an opportunity to optimize early funnel engagement.

### **Recommendations**

• In general, there seems to be a relatively strong conversion rate across devices and traffic sources, the largest drop off occurring between View Item and Add to Cart. In order to increase sales and optimize conversion rates I would recommend the following: 

•	To increase the conversion rate between View Item and Add to Cart

  - Test pricing and discount codes for new visitors

  - Highlight reviews and ratings to encourage adding items to cart (especially considering that the data supports the idea that referrals have the strongest     conversion rate amongst attributable traffic sources)

•	To increase sales, focus efforts for increasing traffic from referrals

  - As the conversion rate is highest from referral traffic we could consider partnerships, influencer marking, or referral incentives to grow this area



### **Notes**

•	Conversion rates for the Unknown traffic source may be inflated due to returning users or blocked attribution (ad blockers, privacy settings).

•	Step counts are strict funnel counts, so later steps only include users who completed all prior steps.

•	Data represents a sample GA4 dataset, not live production data.

