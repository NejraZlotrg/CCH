using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
  
    [ApiController]
    //[AllowAnonymous]
    [Route("api/BPAutodijeloviAutoservis")]
    public class BPAutodijeloviAutoservisController : BaseCRUDController<BPAutodijeloviAutoservis, BPAutodijeloviAutoservisSearchObject, BPAutodijeloviAutoservisInsert, BPAutodijeloviAutoservisUpdate>
    {
        public BPAutodijeloviAutoservisController(ILogger<BaseController<BPAutodijeloviAutoservis, BPAutodijeloviAutoservisSearchObject>> logger,
             IBPAutodijeloviAutoservisService Service) : base(logger, Service)
        {
        }



    }
}
