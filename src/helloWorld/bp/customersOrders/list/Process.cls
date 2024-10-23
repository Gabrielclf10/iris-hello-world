Class helloWorld.bp.customersOrders.list.Process Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As helloWorld.bp.customersOrders.list.Request, Output pResponse As helloWorld.bp.customersOrders.list.Response) As %Library.Status
{
    #Dim tSC As %Library.Status
    #Dim orderResponse As helloWorld.bo.orders.list.Response
    #Dim customerResponse As helloWorld.bo.customers.list.Response

    Try {
        Set tSC = pRequest.NewResponse(.pResponse)

        If $$$ISOK(tSC){
            Set customerRequest = ##class(helloWorld.bo.customers.list.Request).%New()
            Set orderRequest = ##class(helloWorld.bo.orders.list.Request).%New()
            Set tSC = ..SendRequestSync("Customers", customerRequest, .customerResponse)

            If $$$ISOK(tSC){
                Set tSC = ..SendRequestSync("Orders", orderRequest, .orderResponse)

                If $$$ISOK(tSC){
                    For i=1:1:customerResponse.Customers.Count(){
                        #Dim customer As helloWorld.obj.customers.Customer = customerResponse.Customers.GetAt(i)

                        Set customerOrder = ##class(helloWorld.obj.customers.CustomerOrders).%New()
                        Set customerOrder.Id = customer.Id
                        Set customerOrder.Name = customer.Name
                        Set customerOrder.Document = customer.Document

                        For j=1:1:orderResponse.Orders.Count()
                        {
                            #Dim order As helloWorld.obj.orders.Order = orderResponse.Orders.GetAt(j)

                            If (customer.Id = order.CustomerId)
                            {
                                Do customerOrder.Orders.Insert(order)
                            }
                        }
                    Do pResponse.CustomersOrders.Insert(customerOrder)
                    }
                }        
            }        
        }
        If $$$ISERR(tSC) Throw ##class(%Exception.StatusException).CreateFromStatus(tSC)
    } Catch (exception) {
        $$$LOGERROR("Error at OnRequest method: " _ exception.DisplayString())
        Return exception.AsStatus()
    }
    Return $$$OK
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
