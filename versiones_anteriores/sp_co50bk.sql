-- encabezado de los estados de cuenta por poliza y morosidad total por poliza (solo con saldo)
-- sis v.2.0 - deivid, s.a.

drop procedure sp_co50bk;

create procedure "informix".sp_co50bk(a_compania  char(3),a_sucursal char(3), a_no_documento char(20), a_fecha_desde date, a_fecha_hasta date, a_reaseg_asumido int default 2, a_user char(8))
returning	char(50),	-- nombre_cliente
			char(100),	-- direccion1
			char(100),  -- direccion2
			char(20),   -- telefono1
			char(20),	-- telefono2
			char(10),   -- apartado
			char(20),	-- no_documento
			date,       -- vigencia_inic
			date,       -- vigencia_final
			char(50),   -- nombre_agente
			char(50),   -- nombre_ramo
			char(50),   -- nombre_subramo
			date,       -- fecha_aviso,
			date,       -- fecha_efectiva
			char(30),   -- estatus_poliza
			date,       -- fecha de cancelacion
			char(7),	-- periodo
			char(50),	-- forma de pago
			char(8),	-- usuario
			char(50),	-- compania
			char(50),
			char(20);   --celular 	
					  	
define _nombre_cliente  	char(50);
define _direccion1      	char(100);
define _direccion2      	char(100);
define _telefono1       	char(20);
define _telefono2       	char(20);
define _apartado        	char(10);
define _no_documento    	char(20);
define _vigencia_inic   	date;
define _vigencia_final  	date;
define _nombre_agente   	char(50);
define _nombre_ramo     	char(50);
define _nombre_subramo  	char(50);
define _cod_agente      	char(5);
define _cod_ramo        	char(3);
define _cod_cliente     	char(10);						
define _cod_subramo     	char(3);
define _no_poliza       	char(10);
define _fecha_aviso_canc	date;
define _fecha_efectiva  	date;
define _estatus_poliza  	integer;
define _estatus         	char(30);
define _fecha_cancelacion	date;
define _cod_tipoprod	 	char(3);
define _periodo2			char(7);
define _periodo				char(7);
define _periodo_vig_fin		char(7);
define _cod_formapag	 	char(3);
define _nom_formapag	 	char(50);
define _compania			char(50);
define _cod_coasegur		char(3);
define _aseg_lider			char(50);
define _celular			    char(20);
let _celular		= "";
let _no_poliza = null;
let _estatus_poliza = 0;
let _estatus= "";
let _fecha_aviso_canc = null;
let _aseg_lider = '';


call sp_sis39(a_fecha_hasta) returning _periodo2;
call sp_sis39(a_fecha_desde) returning _periodo;
call sp_sis01(a_compania)	 returning _compania;


set isolation to dirty read;

-- seleccion del tipo de produccion
	select cod_tipoprod
	  into _cod_tipoprod
	  from emitipro
	 where tipo_produccion = 4;	-- reaseguro asumido

-- datos de la poliza
if a_reaseg_asumido = 2 then
	foreach
		 select vigencia_inic,
		        vigencia_final,
				cod_ramo,
				cod_subramo,
				cod_contratante,
				no_poliza,
				fecha_aviso_canc,
				estatus_poliza,
				fecha_cancelacion,
				cod_formapag
		   into _vigencia_inic,
				_vigencia_final,
				_cod_ramo,
				_cod_subramo,
				_cod_cliente,
				_no_poliza,
				_fecha_aviso_canc,
				_estatus_poliza,
				_fecha_cancelacion,
				_cod_formapag
		   from emipomae
		  where no_documento = a_no_documento
		    and saldo        > 0.00
		    and actualizado  = 1
		  	--and periodo      <= a_periodo
		   	and cod_tipoprod <> _cod_tipoprod -- no incl. reaseguro asumido
	   order by vigencia_inic desc

		   call sp_sis39(_vigencia_final) returning _periodo_vig_fin;

			if _periodo_vig_fin < _periodo then
				continue foreach;
			end if

	   exit foreach;
	end foreach
elif a_reaseg_asumido = 1 then  --incluye reaseg. asumido
	foreach
	 select vigencia_inic,
	        vigencia_final,
			cod_ramo,
			cod_subramo,
			cod_contratante,
			no_poliza,
			fecha_aviso_canc,
			estatus_poliza,
			fecha_cancelacion,
			cod_formapag
	   into _vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_cod_subramo,
			_cod_cliente,
			_no_poliza,
			_fecha_aviso_canc,
			_estatus_poliza,
			_fecha_cancelacion,
			_cod_formapag
	   from emipomae
	  where no_documento = a_no_documento
	    and saldo        > 0.00
	    and actualizado  = 1
	  	--and periodo      <= a_periodo
  	order by vigencia_inic desc

		call sp_sis39(_vigencia_final) returning _periodo_vig_fin;

		if _periodo_vig_fin < _periodo then
			continue foreach;
		end if
		exit foreach;
	end foreach
else
	foreach
	 select vigencia_inic,
	        vigencia_final,
			cod_ramo,
			cod_subramo,
			cod_contratante,
			no_poliza,
			fecha_aviso_canc,
			estatus_poliza,
			fecha_cancelacion,
			cod_formapag
	   into _vigencia_inic,
			_vigencia_final,
			_cod_ramo,
			_cod_subramo,
			_cod_cliente,
			_no_poliza,
			_fecha_aviso_canc,
			_estatus_poliza,
			_fecha_cancelacion,
			_cod_formapag
	   from emipomae
	  where no_documento = a_no_documento
	    and saldo        > 0.00
	    and actualizado  = 1
	  	--and periodo      <= a_periodo
	   	and cod_tipoprod = _cod_tipoprod --solo reaseguro asumido
  		order by vigencia_inic desc

		call sp_sis39(_vigencia_final) returning _periodo_vig_fin;

		if _periodo_vig_fin < _periodo then
			continue foreach;
		end if

	exit foreach;
	end foreach
end if

if _no_poliza is not null then     
	--estatus de la poliza
		if _estatus_poliza = 1 then
			let _estatus = 'vigente';
		elif _estatus_poliza = 2 then
		    let _estatus = 'cancelada';
		elif _estatus_poliza = 3 then
		    let _estatus = 'vencida';
		else
		    let _estatus = 'anulada';
		end if

		let _fecha_efectiva = (_fecha_aviso_canc + 10);

	-- datos del cliente
	select nombre,
	       direccion_1,
		   direccion_2,
		   telefono1,
		   telefono2,
		   apartado,
       celular
	 into  _nombre_cliente,
	       _direccion1,
		   _direccion2,
		   _telefono1,
		   _telefono2,
		   _apartado,
       _celular
	from  cliclien
	where cod_cliente = _cod_cliente;

	-- ramo y subramo
	select nombre
	into   _nombre_ramo
	from  prdramo
	where cod_ramo = _cod_ramo;	

	select nombre
	into   _nombre_subramo
	from  prdsubra
	where cod_ramo = _cod_ramo
	and   cod_subramo = _cod_subramo;

	select nombre
	  into _nom_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;
  	-- agente de la poliza
	   	foreach
		 select cod_agente
		 into   _cod_agente
		 from   emipoagt
		 where  no_poliza = _no_poliza
		 
		 select nombre
		   into _nombre_agente
		   from agtagent
		  where cod_agente = _cod_agente;
		exit foreach;
		end foreach

	select cod_coasegur 
	  into _cod_coasegur
	  from emicoami
	 where no_poliza = _no_poliza;

	if _cod_coasegur is not null then
		select nombre
		  into _aseg_lider
		  from emicoase
		 where cod_coasegur = _cod_coasegur;
	end if
	
	return
	_nombre_cliente,
	_direccion1,
	_direccion2,
	_telefono1,
	_telefono2,
	_apartado,
	a_no_documento,
	_vigencia_inic,
	_vigencia_final,
	_nombre_agente,
	_nombre_ramo,
	_nombre_subramo,
	_fecha_aviso_canc,
	_fecha_efectiva,
	_estatus,
	_fecha_cancelacion,
	_periodo2,
	_nom_formapag,
	a_user,
	_compania,
	_aseg_lider,
			_celular
	with resume;
end if
end procedure;
