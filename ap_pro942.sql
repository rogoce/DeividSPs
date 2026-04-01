-- Procedimiento que Carga los Reclamos Pendientes en un Periodo Dado
-- 
-- Creado    : 05/08/2000 - Autor: Demetrio Hurtado Almanza

-- Modificado: 27/06/2002 - Autor: Amado Perez M. 

	-- Agregando el filtro de Agentes

-- Modificado: 21/01/2006 - Autor: Demetrio Hurtado Almanza

   	-- Se cambio la forma en que se obtiene el porcentace de reaseguro de la retencion, antes se hacia 
	-- usando recrcrea, pero como el reaseguro de los reclamos cambio a que sea a nivel de las transacciones
	-- fue necesario realizar este cambio
--execute procedure sp_rec02('001','001','2016-03',"*","*","*","002,020,023;","*")
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro942;

create procedure "informix".ap_pro942(
a_compania		char(3), 
a_periodo		char(7) 
) 

-- variables para filtros

define v_filtros     char(255);
define _tipo         char(1);

-- variable del procedure

define _numrecla     		char(18);
define _no_reclamo   		char(10);
define _no_tranrec   		char(10);
define _no_poliza    		char(10); 
define _periodo      		char(7);
define _cod_agente    	    char(5);
define _cod_grupo    		char(5);
define _ajust_interno		char(3);
define _cod_sucursal 		char(3);
define _cod_coasegur 		char(3);
define _cod_ramo     		char(3);
define _cod_cober_reas	    char(3);
define _cod_cobertura		char(5);

define _monto_total  		dec(16,2);
define _monto_bruto  		dec(16,2);
define _monto_neto   		dec(16,2);
define _monto_cob   		dec(16,2);
define _porc_coas    		dec(16,4);
define _porc_reas    		dec(16,6);
define _no_documento        char(20);

define _fecha         		date;
define _cod_cober_reas_no	char(3);
define _cnt_cober_reas      smallint;
define _existe              smallint;

define _cod_origen          char(3);
define _cod_subramo         char(3);
define _cod_tipoprod        char(3);
define _asis_legal          smallint;

--set debug file to "sp_rec02.trc ";
--trace on;

set isolation to dirty read;

-- seleccion del codigo de la compania lider
-- y del contrato de retencion


-- Tabla Temporal

create temp table tmp_sinis(
		no_reclamo			char(10)  not null,
		no_poliza			char(10)  not null,
		cod_ramo			char(3)   not null,
		cod_subramo         char(3)   not null,  
		cod_tipoprod        char(3)   not null,
		seleccionado        smallint default 1,
		numrecla            char(20),
		monto_total         dec(16,2),
		primary key (no_reclamo)) with no log;


set isolation to dirty read;

--- Determinar los reclamos con reserva pendiente

foreach 
	select no_reclamo,
		   sum(variacion)
	  into _no_reclamo,	
		   _monto_total
	  from rectrmae 
	 where cod_compania	= a_compania
	   and periodo     	<= a_periodo 
	   and actualizado  	= 1
	 group by no_reclamo
	 order by no_reclamo

	if _monto_total <= 0 then
		continue foreach;
	end if
	
	-- Lectura de la Tablas de Reclamos
	select no_poliza,
           numrecla,
           asis_legal,
		   fecha_documento,
           fecha_reclamo,
           fecha_siniestro,
		   
	  into _no_poliza,
	       _numrecla,
		   _asis_legal
	  from recrcmae
	 where no_reclamo  = _no_reclamo
	   and actualizado = 1;
	   
	if _asis_legal = 1 then
		continue foreach;
	end if
	
	if _no_poliza is null then
		continue foreach;
	end if

    if _numrecla = "00-0000-00000-00" then
	   continue foreach;
	end if;
 
	-- Informacion de Polizas
	select cod_ramo,
	       cod_subramo,
	       cod_origen,
		   cod_tipoprod
	  into _cod_ramo,
	       _cod_subramo,
           _cod_origen,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	 

	-- Actualizacion del Movimiento
	insert into tmp_sinis(
			no_reclamo,
			no_poliza,
			cod_ramo,
			cod_subramo,
			cod_tipoprod)
	values(	_no_reclamo,
			_no_poliza,	
			_cod_ramo,
			_cod_subramo,
			_cod_tipoprod);
	
end foreach



end procedure;
