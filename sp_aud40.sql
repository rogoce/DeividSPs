-- Procedimiento que Crea los Registros para los Auditores (Cobros)
-- 
-- Creado     : 15/09/2004 - Autor: Demetrio Hurtado
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_aud40;

create procedure "informix".sp_aud40()
       returning char(20), varchar(100), varchar(50), varchar(50), varchar(50), smallint, dec(16,2), dec(16,2), dec(16,2);




define _no_reclamo	    char(10);
define _suma_asegurada	dec(16,2);
define _perdida     	dec(16,2);
define _fecha_documento	date;
define _cod_asegurado	char(10);
define _no_motor		char(30);
define _numrecla		char(20);
define _cod_evento      char(3);
define _causa           varchar(50);
define _nom_asegurado  	varchar(100);
define _cod_marca 		  char(5);
define _cod_modelo 		  char(5);
define _ano_auto		  smallint;
define _marca			  varchar(50);
define _modelo			  varchar(50);
define _salvamento     	dec(16,2);

set isolation to dirty read;

foreach with hold
 select no_reclamo,
        suma_asegurada,
      	perdida
   into _no_reclamo,
        _suma_asegurada,
		_perdida
   from recperdida

 select fecha_documento,
	    cod_asegurado,
		no_motor,
		cod_evento,
		numrecla
   into _fecha_documento,
        _cod_asegurado,
	    _no_motor,
		_cod_evento,
		_numrecla
   from recrcmae
  where no_reclamo = _no_reclamo;
  
  if _fecha_documento < '01/01/2010' then
  	continue foreach;
  end if	

	select nombre 
	  into _nom_asegurado
	  from cliclien
	 where cod_cliente = _cod_asegurado;
 
	select nombre
	  into _causa
	  from recevent
	 where cod_evento = _cod_evento;

    select cod_marca, cod_modelo, ano_auto
	  into _cod_marca, _cod_modelo, _ano_auto
	  from emivehic
	 where no_motor = _no_motor;

    SELECT nombre
	  INTO _marca
	  FROM emimarca
	 WHERE cod_marca = _cod_marca;

    SELECT nombre
	  INTO _modelo
	  FROM emimodel
	 WHERE cod_marca  = _cod_marca
	   AND cod_modelo = _cod_modelo;  

   let _salvamento = 0.00;

   select sum(monto)
     into _salvamento
	 from rectrmae
	where no_reclamo = _no_reclamo
	  and cod_tipotran = '005';

   return _numrecla, _nom_asegurado, _causa, _marca, _modelo, _ano_auto, _suma_asegurada, _perdida, _salvamento with resume; 


end foreach

--unload to recibos.txt select no_recibo from tmp_recibos;

end procedure