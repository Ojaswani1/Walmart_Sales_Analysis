# Walmart_Sales_Analysis
🔗 Dataset: https://www.kaggle.com/datasets/najir0123/walmart-10k-sales-datasets
This project analyzes **Walmart sales data (10K rows)** using **Python, SQL, and Tableau** to uncover trends, optimize revenue strategies, and predict future sales.

## 🛠 Technologies Used
- **Python**: Data cleaning, EDA, and visualization (*Pandas, Seaborn, Matplotlib*)
- **SQL (MySQL)**: Querying and insights generation
- **Tableau**: Interactive dashboard for sales & profit analysis

---

## 📊 Data Cleaning & Preprocessing

### **Exploratory Data Analysis (EDA)**
✔ Checked for **missing values, duplicate records, and incorrect data types**  
✔ Calculated **Total Price** = `Unit Price × Quantity`  

### **Time Series Analysis**
✔ **Monthly Sales Trend**  
✔ **Sales by Day of the Week**  
✔ **Hourly Sales Pattern**  

### **Sales & Profit Analysis**
✔ **Total & Average Sales Calculation**  
✔ **Profit Analysis by Category**  

### **Customer Behavior Analysis**
✔ **Preferred Payment Methods**  
✔ **Customer Ratings Distribution**  

---

## 📂 SQL Database & Queries
✔ **Stored cleaned dataset in MySQL using SQLAlchemy**  
✔ **Created a new table for Walmart sales**  
✔ **Performed complex SQL queries** to analyze **sales trends, product performance, and customer behavior**  

### 🔎 **Key SQL Insights (Sample Questions)**

#### ✅ **Sales & Revenue Insights**
- Identify **branches with highest revenue decline** (YoY)  
- **Total profit by category** (ranked)  
- **Top 3 most profitable products per city**  
- **Peak sales hours & customer traffic patterns**  
- **Predicting future sales trends**  

#### ✅ **Product Performance & Market Trends**
- Identify **best-selling categories by quarter**  
- **Most common payment method per branch**  
- **Branch-specific low ratings**  

#### ✅ **Operational & Branch Performance**
- **Pareto Analysis**: Top **5 branches contributing to 80% of total revenue**  
- **Recursive queries** for branch revenue comparison  
- **Stored procedures** to get **branch-wise sales on demand**  

---

## 📊 Tableau Dashboard  
Designed an **interactive sales dashboard** with filters for branch-wise analysis.

### **Key Metrics & Visualizations**
✔ **KPIs:**  
  - 📌 **Total Sales**  
  - 📌 **Total Profit**  
  - 📌 **Total Quantity**  

✔ **Visualizations:**  
  - 📊 **Sales by Category**  
  - 📊 **Hourly Sales Trend**  
  - 📊 **Payment Method Distribution**  
  - 📊 **Customer Satisfaction Trend**  
  - 📊 **Top 10 Branches with Highest Profit**  

🔗 **[View Tableau Dashboard](#)**  

---

## 🚀 **How to Use**
1. **Clone the repository:**  
   ```bash
   git clone https://github.com/yourusername/walmart-sales-analysis.git
   cd walmart-sales-analysis
