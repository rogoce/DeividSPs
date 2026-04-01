-- Procedimiento que trae los encabezados pagos externos.
-- Creado    : 7/04/2009 - Autor: Henry Giron.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob160;

create procedure sp_cob160()
returning char(10),  --no_remesa_ancon
		  char(10),  --numero
       	  date,		 --fecha_adicion
		  char(10),	 --usuario
	      char(50),	 --nombrecorredor
   	      char(10),	 --numero de remesa
       	  date,		 --fecha_remesa
		  dec(16,2), 
		  dec(16,2), 
		  dec(16,2), 
		  dec(16,2), 
		  dec(16,2), 
		  dec(16,2), 
	      char(6),
	      date,
	      date,
	      char(10),
   	      date;

define _fecha_adicion 		date;
define _periodo_desde 		date;
define _periodo_hasta 		date;
define _fecha_remesa 		date;
define _fecha_recibo 		date;
define _usuario		    	char(10);
define _no_recibo_ancon    	char(10);
define _no_remesa_ancon		char(10);
define _numero		    	char(10);
define _no_remesa			char(10);
define _cod_subramo	    	char(3);
define _no_cheque	    	char(6);
define _gestion				char(1);
define _ramo_nom			char(50);
define _periodo,_peri		char(7);
define _subramo_nom			char(50);
define _mes_char        	char(2);
define _ano_char			char(4);
define _nombre_agente		char(50);
define _cod_agente			char(10);
define _estatus_poliza  	smallint;
define _ramo_sis			smallint;
define _tipo_formato		smallint;
define _monto_total			dec(16,2);
define _monto_comis			dec(16,2);
define _monto_comis_cobro	dec(16,2);
define _monto_comis_visa	dec(16,2);
define _monto_comis_clave	dec(16,2);
define _monto_bruto			dec(16,2);

set isolation to dirty read;

foreach

 select no_remesa_ancon,
 		numero,
		fecha_adicion,
		usuario,
		cod_agente,
		no_remesa,
		fecha_remesa,
		monto_total,
		monto_comis,
		monto_comis_cobro,
		monto_comis_visa,
		monto_comis_clave,
		monto_bruto,
		no_cheque,
		periodo_desde,
		periodo_hasta,
		no_recibo_ancon,
		fecha_recibo,
		tipo_formato
   into	_no_remesa_ancon,
   		_numero,
		_fecha_adicion,
		_usuario,
		_cod_agente,
		_no_remesa,
		_fecha_remesa,
		_monto_total,
		_monto_comis,
		_monto_comis_cobro,
		_monto_comis_visa,
		_monto_comis_clave,
		_monto_bruto,
		_no_cheque,
		_periodo_desde,
   		_periodo_hasta,
		_no_recibo_ancon,
		_fecha_recibo,
		_tipo_formato
   from cobpaex0
  where insertado_remesa = 0
  order by numero

	if _tipo_formato = 1 then
		select nombre
		  into _nombre_agente
		  from agtagent
		 where cod_agente = _cod_agente;

	elif _tipo_formato = 2 then
		select nombre
		  into _nombre_agente 
		  from emicoase
		 where cod_coasegur = _cod_agente;
	elif _tipo_formato = 3 then
		select nombre
		  into _nombre_agente
		  from cliclien
		 where cod_cliente = _cod_agente;
	end if

	return _no_remesa_ancon,
		   _numero,
	       _fecha_adicion,
		   _usuario,
		   _nombre_agente,
		   _no_remesa,
		   _fecha_remesa,
		   _monto_total,
		   _monto_comis,
		   _monto_comis_cobro,
		   _monto_comis_visa,
		   _monto_comis_clave,
		   _monto_bruto,
		   _no_cheque,
		   _periodo_desde,
		   _periodo_hasta,
		   _no_recibo_ancon,
		   _fecha_recibo
		   with resume;
end foreach
end procedure