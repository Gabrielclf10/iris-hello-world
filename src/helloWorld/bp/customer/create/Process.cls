Class helloWorld.bp.customer.create.Process Extends Ens.BusinessProcess
{

Method OnRequest(pRequest As helloWorld.bp.customer.create.Request, Output pResponse As helloWorld.bp.customer.create.Response) As %Library.Status
{
    #Dim tSC As %Library.Status
    #Dim customerResquest As helloWorld.bo.customers.create.Request
    #Dim customerResponse As helloWorld.bo.customers.create.Response

    Try {
        Set tSC = pRequest.NewResponse(.pResponse)

        If $$$ISOK(tSC){
            If (pRequest.action = "create"){
                Set customerRequest = ##class(helloWorld.bo.customers.create.Request).%New()
            } Else {
                Set customerRequest = ##class(helloWorld.bo.customers.update.Request).%New()
            }

            Set customerRequest.Customer = pRequest.Customer

            Set tSC = ..SendRequestSync("Customers", customerRequest, .customerResponse)
            
            If $$$ISOK(tSC){
                #Dim customer As helloWorld.obj.customers.Customer = customerResponse.Customer

                Set customer = ##class(helloWorld.obj.customers.CustomerOrders).%New()
                Set customer.Id = customerResponse.Customer.Id
                Set customer.Name = customerResponse.Customer.Name
                Set customer.Document = customerResponse.Customer.Document

                Set pResponse.Customer = customer
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
