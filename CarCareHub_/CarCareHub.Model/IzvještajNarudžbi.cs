namespace CarCareHub.Model
{
    public class IzvjestajNarudzbi
    {
        public int NarudzbaId { get; set; }
        public DateTime? DatumNarudzbe { get; set; }
        public string Klijent { get; set; }
        public string Autoservis { get; set; }
        public string Zaposlenik { get; set; }
        public decimal? UkupnaCijena { get; set; }
        public bool? Status { get; set; }
    }
}
