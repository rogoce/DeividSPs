--barre las polizas con forma de pago ancon, y evalua la cantidad de dias que tiene para entrar al callcenter
--si tiene mas de 21 dias sin entrar al callcenter entonces manda error en diarios sis101.
drop procedure sp_cas079;

create procedure "informix".sp_cas079()
returning smallint,
          char(20),
          char(3),
          char(50),
          dec(16,2),
          char(10),
          char(1),
          char(50),
          smallint,
          char(10);

define _no_documento	char(20);
define _no_poliza		char(10);
define _cantidad		smallint;
define _cod_formapag	char(3);
define _nombre_forma	char(50);
define _estatus			smallint;
define _saldo			dec(16,2);
define _estatus_char	char(10);
define _cod_tipoprod	char(3);
define _cobra_poliza	char(1);
define _nombre_cobra	char(50);
define _fecha_emision   date;
define _dias,_return  	smallint;
define _periodo			char(7);

set isolation to dirty read;

let _periodo = sp_sis39(today);

foreach
 select no_documento 
   into _no_documento
   from emipomae
  where cod_formapag = "006"   --forma de pago ANCON
    and actualizado  = 1
  group by 1

	let _no_poliza = sp_sis21(_no_documento);

	select cod_formapag,
	       estatus_poliza,
		   cod_tipoprod,
		   cobra_poliza,
		   fecha_suscripcion
	  into _cod_formapag,
	       _estatus,
		   _cod_tipoprod,
		   _cobra_poliza,
		   _fecha_emision
	  from emipomae
	 where no_poliza = _no_poliza;

	if _estatus <> 1 then	--solo vigentes
		continue foreach;
	end if

	if _cod_tipoprod = "002" or
	   _cod_tipoprod = "004" then
		continue foreach;
	end if
	
	if _cod_formapag <> "006" then	 --solo forma de pago "ANCON"
		continue foreach;
	end if

	select count(*)
	  into _cantidad
	  from caspoliza
	 where no_documento = _no_documento;

	if _cantidad = 0 then

		let _saldo = sp_cob175(_no_documento, _periodo);

		if _saldo = 0.00 then
			continue foreach;
		end if

		if _cobra_poliza = 'A' THEN
			let _dias = today - _fecha_emision;

			if _dias <= 21 then
				continue foreach;
			end if
		else
		   let _dias = 0;
		end if

		select nombre
		  into _nombre_forma
		  from cobforpa
		 where cod_formapag = _cod_formapag;

		if _estatus = 1 then
			let _estatus_char = "Vigente";
		elif _estatus = 2 then
			let _estatus_char = "Cancelada";
		elif _estatus = 3 then
			let _estatus_char = "Vencida";
		elif _estatus = 4 then
			let _estatus_char = "Anulada";
		end if

		IF _cobra_poliza = 'E' THEN
		  LET _nombre_cobra = 'CALL CENTER'; 
		ELIF _cobra_poliza = 'G' THEN            
		  LET _nombre_cobra = 'GERENCIA'; 
		ELIF _cobra_poliza = 'I' THEN            
		  LET _nombre_cobra = 'INCOBRABLES'; 
		ELIF _cobra_poliza = 'T' THEN
		  LET _nombre_cobra = 'TARJETA CREDITO'; 
		ELIF _cobra_poliza = 'H' THEN            
		  LET _nombre_cobra = 'ACH'; 
		ELIF _cobra_poliza = 'C' THEN            
		  LET _nombre_cobra = 'CORREDOR'; 
		ELSE
		  LET _nombre_cobra = _cobra_poliza; 
		end if

		let _return = sp_cas022(_no_poliza);
		return 1,
			   _no_documento,
			   _cod_formapag,
			   _nombre_forma,
			   _saldo,
			   _estatus_char,
			   _cobra_poliza,
			   _nombre_cobra,
			   _dias,
			   _no_poliza
			   with resume;
			   
	end if
	
end foreach

return 0,
	   "",
	   "",
	   "",
	   0,
	   "",
	   "",
	   "",
	   0,
	   ""
	   with resume;
	

end procedure