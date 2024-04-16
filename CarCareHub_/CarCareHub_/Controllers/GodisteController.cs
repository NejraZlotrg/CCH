using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;
using CarCareHub.Services;

namespace CarCareHub_.Controllers
{
    public class GodisteController : BaseCRUDController<Godiste, GodisteSearchObject, GodisteInsert, GodisteUpdate>
    {
        public GodisteController(ILogger<BaseController<Godiste, GodisteSearchObject>> logger,
             IGodisteService Service) : base(logger, Service)
        {
        }
    }
}
