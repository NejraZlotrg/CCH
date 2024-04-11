using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface IKlijentService : ICRUDService<Model.Klijent, KlijentSearchObject, KlijentInsert, KlijentUpdate>
    {

    }
}