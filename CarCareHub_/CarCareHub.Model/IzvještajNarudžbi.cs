namespace CarCareHub.Model
{
    public class IzvjestajNarudzbi
    {
        public int NarudzbaId { get; set; }
        public DateTime? DatumNarudzbe { get; set; }
        public Klijent? Klijent { get; set; } // Nullable Klijent
        public Autoservis? Autoservis { get; set; } // Nullable Autoservis
        public Zaposlenik? Zaposlenik { get; set; } // Nullable Zaposlenik
        public decimal? UkupnaCijena { get; set; }
        public bool? Status { get; set; }
    }
}