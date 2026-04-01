-- Devoluciones de Primas

-- Creado    : 07/09/2010 - Autor: Demetrio Hurtado Almanza 

drop procedure sp_cob250; 

create procedure "informix".sp_cob250()
returning char(7),
          char(20),
		  char(50),
          dec(16,2),
          char(10),
          char(255),
          char(255);

define _no_requis		char(10);
define _periodo			char(7);
define _a_nombre		char(50);

define _no_documento	char(20);
define _monto			dec(16,2);

define _desc_cheque		char(100);
define _descripcion1	char(255);
define _descripcion2	char(255);
define _renglon			smallint;

foreach
 select periodo,
        a_nombre_de,
		no_requis
   into _periodo,
        _a_nombre,
		_no_requis
   from chqchmae
  where pagado        = 1
    and anulado       = 0
	and origen_cheque = "6"
	and periodo       >= "2010-01"

	foreach
	 select no_documento,
	        monto
	   into _no_documento,
	        _monto
	   from chqchpol
	  where no_requis = _no_requis

		let _descripcion1 = "";
		let _descripcion2 = "";

		foreach
		 select desc_cheque,
		        renglon
		   into _desc_cheque,
		        _renglon
		   from chqchdes
		  where no_requis = _no_requis
		  order by renglon

			if _renglon <= 2 then

				let _descripcion1 = trim(_descripcion1) || trim(_desc_cheque);
						 
			elif _renglon = 3 then
				
				let _descripcion1 = trim(_descripcion1) || trim(_desc_cheque[1,50]);
				let _descripcion2 = trim(_descripcion2) || trim(_desc_cheque[51,100]);
			
			elif _renglon >= 4 then

				let _descripcion2 = trim(_descripcion2) || trim(_desc_cheque);

			end if

		end foreach


		return _periodo,
		       _no_documento,
			   _a_nombre,
		       _monto,
			   _no_requis,
			   _descripcion1,
			   _descripcion2
		       with resume;

	end foreach	   

end foreach

return "",
       "",
	   "",
       0,
       "",
	   "",
	   ""
       with resume;

end procedure
