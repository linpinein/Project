import pandas as pd

##################################################################################################################################################################################################
# 1. 匯入資料
##################################################################################################################################################################################################

Path_1 = r"C:\Users\Lin\OneDrive\Desktop\言\Sideproject\Uber Eats熱門餐廳 特徵分析\excel\原資料庫\restaurant-menus.csv"
Path_2 = r"C:\Users\Lin\OneDrive\Desktop\言\Sideproject\Uber Eats熱門餐廳 特徵分析\excel\原資料庫\restaurants.csv"

Restaurant_Menus = pd.read_csv(Path_1)
Restaurants = pd.read_csv(Path_2)

##################################################################################################################################################################################################
# 2. 數據摘要，修正格式
##################################################################################################################################################################################################

Restaurant_Menus['price'] = Restaurant_Menus['price'].str.replace(' USD','').str.strip()            # 移除 USD文字，排除頭尾空白值
Restaurant_Menus['price'] = pd.to_numeric(Restaurant_Menus['price'] , errors = "coerce")            # 轉換為數值型態，不能轉換的設為nan

# Restaurants.info()
# Restaurant_Menus.info()

##################################################################################################################################################################################################
# 3. 刪除不需要的columns
##################################################################################################################################################################################################

Restaurants = Restaurants.drop('zip_code' , axis = 1)
Restaurant_Menus = Restaurant_Menus.drop('description' , axis = 1)

##################################################################################################################################################################################################
# 4. 抓出restaurant.csv中，德克薩斯州(TX)的資料
##################################################################################################################################################################################################

Restaurants['full_address'] = Restaurants['full_address'].str.replace('Texas','TX')                 # 將 full_address裡的Texas 轉換成 TX
Restaurants['States_Abbr'] = Restaurants['full_address'].str.split(',').str[-2].str.strip()         # 從 full_address以「，」切割，取倒數第2段，去首尾空白值，命名「州名縮寫」

TX_Restaurant = Restaurants[Restaurants['States_Abbr'] == 'TX']                                     # 抓出德州 TX 資料

##################################################################################################################################################################################################
# 5. 清理columns資訊
##################################################################################################################################################################################################

TX_Restaurant = TX_Restaurant.rename(columns = {'name':'Restaurant_Name',                           # 修改columns名稱
                                                'ratings':'Comments',
                                                'id':'Restaurant_Id',
                                                'category':'Restaurant_Category',
                                                'price_range':'Restaurant_Price_Range',
                                                'full_address':'Address'})

Restaurant_Menus = Restaurant_Menus.rename(columns = {'name':'Food_Name',                           # 修改columns名稱
                                                      'category':'Food_Category'})

TX_Restaurant.columns = TX_Restaurant.columns.str.title()                                           # columns名稱改為Snake Cake型式
Restaurant_Menus.columns = Restaurant_Menus.columns.str.title()

new_columns_order = ['Restaurant_Id','Restaurant_Name','Position',                                  # 重新排序columns，列出自訂的順序
                     'Restaurant_Category','Restaurant_Price_Range',
                     'Score','Comments','Address','States_Abbr','Lat','Lng']

TX_Restaurant = TX_Restaurant[new_columns_order]                                                    # 套用至原來的 Dataframe

new_columns_order_1 = ['Restaurant_Id','Food_Name',                                                 # 同上
                       'Food_Category','Price']

Restaurant_Menus = Restaurant_Menus[new_columns_order_1]

##################################################################################################################################################################################################
# 6. 檢查、排除缺失值
##################################################################################################################################################################################################

data_num = TX_Restaurant.shape[0]                                                                                                           # TX_Restaurant的總行數（有幾筆資料）

for i in TX_Restaurant.columns:                                                                                                             # 帶入每個 columns
    print(f"{i}共有{TX_Restaurant[i].isna().sum()}個缺失數，{round( TX_Restaurant[i].isna().sum() / data_num * 100 , 2 )}%的缺失值")          # 共有幾個缺失數，幾%的缺失值（缺失值% = 缺失值總數 ÷ 行數）

TX_Restaurant.dropna(subset = ['Score','Comments',                                                                                          # 排除這些欄位的空值
                               'Restaurant_Price_Range',
                               'Restaurant_Category'] , inplace = True)                                                                     # inplace = True：直接在原始的 DataFrame 執行操作

Lat_Lng_0 = TX_Restaurant[(TX_Restaurant['Lat'] == 0) & (TX_Restaurant['Lng'] == 0)].index                                                  # 找出經緯度 = 0 的數據，找出該列索引值（.index），存在 Lat_Lng_0 變數
TX_Restaurant = TX_Restaurant.drop(Lat_Lng_0)                                                                                               # 根據 Lat_Lng_0 中的 索引，從原資料表排除對應列

##################################################################################################################################################################################################
# 7. 檢查重複值
##################################################################################################################################################################################################
    
dup_count = TX_Restaurant[TX_Restaurant.duplicated()]                                                               # 全體數據檢查，抓整列資料一樣的數據
dup_count_1 = TX_Restaurant[TX_Restaurant.duplicated(subset = ['Restaurant_Id','Restaurant_Name'])]                 # 針對 Id、Restaurant_Name 再檢查，防止同間餐廳資料被重複輸入

##################################################################################################################################################################################################
# 8. 提取TX的菜單資訊
##################################################################################################################################################################################################
    
TX_Restaurant_Menus = Restaurant_Menus[Restaurant_Menus['Restaurant_Id'].isin(TX_Restaurant['Restaurant_Id'])]      # 先取出 TX_Restaurant 的 ID，比對 Restaurant_Menus 的 ID 是否有共通，篩選有共通的 ID 並另存為 TX_Restaurant_Menus

TX_Restaurant_Menus = TX_Restaurant_Menus.reset_index(drop=True)                                                    # 重設菜單資料的索引，刪除原本的 index（避免保留舊索引）
TX_Restaurant = TX_Restaurant.reset_index(drop=True)

##################################################################################################################################################################################################
# 9. 匯出
##################################################################################################################################################################################################

TX_Restaurant.to_csv('TX_Init_Restaurant.csv' , index=False)
TX_Restaurant_Menus.to_csv('TX_Init_Restaurant_Menus.csv' , index=False)