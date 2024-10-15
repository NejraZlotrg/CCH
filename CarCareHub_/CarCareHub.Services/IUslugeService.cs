using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IUslugeService : ICRUDService<Model.Usluge, UslugeSearchObject, UslugeInsert, UslugeUpdate>
    {
    }
}