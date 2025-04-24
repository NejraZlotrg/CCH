using CarCareHub.Model;
using CarCareHub.Model.SearchObjects;

namespace CarCareHub.Services
{
    public interface IDrzavaService : ICRUDService<Drzava, DrzavaSearchObject, DrzavaInsert, DrzavaUpdate>
    {
        Task AddDrzavaAsync();
    }
}
