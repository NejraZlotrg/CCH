namespace CarCareHub.Model
{
    public class IzvjestajNarudzbi
    {
        public int NarudzbaId { get; set; }
        public DateTime? DatumNarudzbe { get; set; }
        public Klijent? Klijent { get; set; } 
        public Autoservis? Autoservis { get; set; }
        public Zaposlenik? Zaposlenik { get; set; }
        public decimal? UkupnaCijena { get; set; }
        public bool? Status { get; set; }
    }
}