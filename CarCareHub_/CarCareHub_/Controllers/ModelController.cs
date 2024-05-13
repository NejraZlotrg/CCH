using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CarCareHub_.Controllers
{
    [ApiController]
    //[AllowAnonymous]
    [Route("api/model")]
    public class ModelController : BaseCRUDController<Model, ModelSearchObject, ModelInsert, ModelUpdate>
    {
        public ModelController(ILogger<BaseController<Model, ModelSearchObject>> logger,
             IModelService Service) : base(logger, Service)
        {
        }
    }
}
