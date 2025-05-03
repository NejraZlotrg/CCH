using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface INarudzbaService : ICRUDService<Model.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>
    {
        public Task<Model.Narudzba> PotvrdiNarudzbu(int narudzbaId);
        public Task<List<Model.Narudzba>> GetByLogeedUser_(int id);
        public Task<List<IzvjestajNarudzbi>> GetIzvjestajNarudzbi(DateTime? datumOd, DateTime? datumDo, int? klijentId, int? zaposlenikId, int? autoservisId);
        public Task<List<Model.Narudzba>> GetNarudzbeZaFirmu(int id);
        public Task<List<AutoservisIzvjestaj>> GetAutoservisIzvjestaj();
        public Task<List<KlijentIzvjestaj>> GetNarudzbeZaSveKlijente();
        public  Task<List<ZaposlenikIzvjestaj>> GetNarudzbeZaSveZaposlenike();
        public  Task AddSampleNarudzbeAsync();
        
    }
}