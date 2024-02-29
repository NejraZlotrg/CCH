
using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub_.Controllers


{
    [ApiController]
   [Route("controllerGrad")]
    public class GradController:BaseController<CarCareHub.Model.Grad, GradSearchObject>
    {
      

        public GradController(ILogger<BaseController<CarCareHub.Model.Grad, GradSearchObject>> logger, IGradService service):base(logger, service)
        {
            
        }

       
    }
}




