using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface IVoziloService : ICRUDService<Vozilo, VoziloSearchObject, VoziloInsert, VoziloUpdate>
    {
    }
}