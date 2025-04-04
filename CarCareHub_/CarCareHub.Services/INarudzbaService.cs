using CarCareHub.Model.SearchObjects;
using CarCareHub.Model;

namespace CarCareHub.Services
{
    public interface INarudzbaService : ICRUDService<Model.Narudzba, NarudzbaSearchObject, NarudzbaInsert, NarudzbaUpdate>
    {
        public Task<Model.Narudzba> PotvrdiNarudzbu(int narudzbaId);

        // public  Task<Model.Narudzba> DodajStavkuUKosaricu(int proizvodId, int kolicina);

        public Task<List<Model.Narudzba>> GetByLogeedUser_(int id);

        public Task<List<IzvjestajNarudzbi>> GetIzvjestajNarudzbi(DateTime? datumOd, DateTime? datumDo, int? klijentId, int? zaposlenikId, int? autoservisId);
        public Task<List<Model.Narudzba>> GetNarudzbeZaFirmu(int id);
        public Task<List<AutoservisIzvjestaj>> GetAutoservisIzvjestaj();

    }
}