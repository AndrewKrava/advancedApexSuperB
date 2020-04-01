public Without Sharing class ChartHelper {

    @AuraEnabled
    public static List<chartData> GetInventory(){
        List<chartData> cht = new List<chartData>();
        //ToDo: Perform a calculation that aggregates active Products that have a positive Quantity_Remaining__c
        List<AggregateResult> aggProducts = [
                                    SELECT SUM(Quantity_Remaining__c) Qty, Family
                                    FROM Product2
                                    WHERE IsActive = true AND Quantity_Remaining__c > 0
                                    GROUP BY Family
                                    ];
        //  And return a list of chartData
        //  Where the name is the Product Family and the Qty is the sum of the Quantity_Remaining__c
        for (AggregateResult item : aggProducts) {
            //cht.add({'name': (String)item.get('Family'), 'Qty': (Decimal)item.get('remaning')});
            ChartData data = new ChartData((String)item.get('Family'), (Decimal)item.get('Qty'));
            cht.add(data);
        }
        return cht;
    }

    public class ChartData {
        public String name {get;set;}
        public Decimal val {get;set;}

        public ChartData(String name, Decimal val){
            this.name = name;
            this.val = val;
        }
    }

}