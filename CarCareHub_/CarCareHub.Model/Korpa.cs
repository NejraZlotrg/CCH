using System;
using System.Collections.Generic;

namespace CarCareHub.Model
{
    public class Korpa
    {
        public int? ProizvodId { get; set; }

        public int? Kolicina { get; set; }

        public decimal? UkupnaCijenaProizvoda { get; set; }

        public virtual Proizvod? Proizvod { get; set; }

        public int? KlijentId { get; set; }

        public virtual Klijent? Klijent { get; set; }
        public bool Vidljivo { get; set; }
        public int? AutoservisId { get; set; }
        public virtual Autoservis? Autoservis { get; set; }

        public int? ZaposlenikId { get; set; }
        public virtual Zaposlenik? Zaposlenik { get; set; }


        // Metoda za prikazivanje samo ne-null ID-ova
        public Dictionary<string, int?> GetNonNullIds()
        {
            var result = new Dictionary<string, int?>();

            if (KlijentId.HasValue)
                result.Add("KlijentId", KlijentId);

            if (AutoservisId.HasValue)
                result.Add("AutoservisId", AutoservisId);

            if (ZaposlenikId.HasValue)
                result.Add("ZaposlenikId", ZaposlenikId);

            return result;
        }
    }
}
