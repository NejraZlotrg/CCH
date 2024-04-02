using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;
using CarCareHub.Services;

namespace CarCareHub_.Controllers
{
    public class UslugeController : BaseCRUDController<Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>
    {
        public UslugeController(ILogger<BaseController<CarCareHub.Model.Usluge, UslugeSearchObject>> logger,
             ICRUDService<Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate> service) : base(logger, service)
        {
        }
    }
}
