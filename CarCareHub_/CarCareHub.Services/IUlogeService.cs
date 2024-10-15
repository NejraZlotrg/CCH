using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IUlogeService : ICRUDService<Model.Uloge, UlogeSearchObject, UlogeInsert, UlogeUpdate>
    {
    }
}