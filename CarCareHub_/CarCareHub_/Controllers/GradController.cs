
using Microsoft.AspNetCore.Mvc;
using CarCareHub.Services;
using CarCareHub.Services.Database;
using CarCareHub.Model;
using CarCareHub;
using CarCareHub.Model.SearchObjects;
using Microsoft.AspNetCore.Authorization;

namespace CarCareHub_.Controllers


{
    [ApiController]
    [AllowAnonymous]
   [Route("controllerGrad")]
    public class GradController:BaseController<CarCareHub.Model.Grad, GradSearchObject>
    {
      

        public GradController(ILogger<BaseController<CarCareHub.Model.Grad, GradSearchObject>> logger, IGradService service):base(logger, service)
        {
            
        }

       
    }
}




