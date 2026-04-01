--*****************************************************************
-- Procedimiento que genera prima suscrita anualizada de ramo: 019- VIDA INDIVIDUAL 
--*****************************************************************
--execute procedure sp_che164("001","001","2018-01","HGIRON")
-- Creado    : 22/01/2018 - Autor: Henry Giron

DROP PROCEDURE sp_che164;
CREATE PROCEDURE sp_che164(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo char(7),a_usuario CHAR(8))
RETURNING SMALLINT,
            char(100),
		    char(7);


define _cod_grupo       char(5);
define _estatus_poliza	smallint;
			
define _prima_neta  dec(16,2);
define _saldo			dec(16,2);   
define _por_vencer		dec(16,2);
define _corriente		dec(16,2);
define _exigible		dec(16,2);
define _monto_30		dec(16,2);
define _monto_60		dec(16,2);
define _monto_90		dec(16,2);
define _monto_bono		dec(16,2);
define _porc_bono		dec(9,4);
define _porc_partic_agt dec(5,2);
define _no_poliza       char(10);
define _no_documento    char(20); 
define _cod_tipoprod    char(3); 
define _estatus_licencia char(1);
define _tipo_agente     char(1);
define _cod_producto	char(5);
define _cod_formapag    char(3);
define _periodo			char(7);  
define _cod_agente_anterior   	char(5);
define _cod_agencia		char(3);
define _suc_promotoria	char(3);
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _cod_subramo		char(3); 
define _cod_origen		char(3);
define _cod_contratante	char(10);
define _nombre_clte	    char(100);
define _vigencia_inic	date;
define _vigencia_final	date;
define _fecha_hoy		date;
define _pagada          smallint;
define _unificar        smallint;
define _vigente         smallint;
define _error           smallint;
define _flag            smallint;
define _cnt_existe      smallint;
define _cnt             integer;
DEFINE _fecha_actual	date;
DEFINE _mes_char		char(2);
DEFINE _ano_char		char(4);
DEFINE _periodo_c		char(7);
define _porc_coaseguro  dec(9,4);
define _descripcion     char(100);
define _prima_sus_agt   dec(16,2);
define _licencia        char(10);
define _tipo_pago       smallint;
define _cod_agente   	char(5);
define _nombre          char(50);
define _cod_ramo        char(3);  
define _nombre_ramo     char(50);
define _periodo_ant     CHAR(7);
define _cod_perpago     char(3);
define _anio_ant		smallint;

SET DEBUG FILE TO "sp_che164.trc";
TRACE ON;

let _flag            = 0;
let _cnt             = 0;
let _error           = 0;
let _porc_partic_agt = 0.00;
let _prima_neta  = 0.00;
let _monto_bono      = 0.00;
let _porc_bono       = 0.00;
let _prima_sus_agt   = 0.00;
let _porc_coaseguro  = 0.00;
let _saldo           = 0.00;
let _nombre_clte     = '';
let _descripcion     = '';

let _fecha_actual = sp_sis26() ;
IF MONTH(_fecha_actual) < 10 THEN
	LET _mes_char = '0'|| MONTH(_fecha_actual);
ELSE
	LET _mes_char = MONTH(_fecha_actual);
END IF

LET _ano_char = YEAR(_fecha_actual);
LET _periodo_c  = _ano_char || "-" || _mes_char;

delete from chqbono019 where periodo = a_periodo;
delete from chqbono019e where periodo = a_periodo;

SET ISOLATION TO DIRTY READ;
--*****************************
-- Polizas Nuevas
--*****************************
foreach
	select e.no_documento,
			e.no_poliza,			
			e.cod_tipoprod,
			e.prima_neta,
			e.cod_formapag,sucursal_origen,cod_ramo,cod_subramo,cod_origen,cod_contratante,e.cod_perpago
	   into _no_documento,
			_no_poliza,			
			_cod_tipoprod,
			_prima_neta,
			_cod_formapag,_cod_agencia, _cod_ramo, _cod_subramo,_cod_origen,_cod_contratante,_cod_perpago
	  from emipomae e
	  join emiletra l on e.no_poliza = l.no_poliza
	where cod_compania = '001'
	   and e.actualizado = 1
	   and e.estatus_poliza = 1
	   and e.nueva_renov = 'N'
	   and e.periodo  = a_periodo
	   and e.cod_ramo = '019'
	   and l.no_letra = 1
	   and l.pagada   = 1
 

	if _cod_tipoprod in ("004") then   -- Excluir Reaseguro Asumido   
	    continue foreach;
	elif _cod_tipoprod = "001" then	   -- Coaseguro Mayoritario, se debe sacar solo la parte de ancon.
		select porc_partic_coas
		  into _porc_coaseguro
		  from emicoama
		 where no_poliza    = _no_poliza
		   and cod_coasegur = '036';

		if _porc_coaseguro is null then
			let _porc_coaseguro = 0.00;
		end if

		let _prima_neta = _prima_neta * (_porc_coaseguro / 100);
		let _prima_cobrada = _prima_cobrada * (_porc_coaseguro / 100);
	end if
	
	select count(*)								--  Pto-6  No tener polizas rehabilitadas
	  into _cnt
	  from endedmae
	 where actualizado = 1
	   and no_poliza   = _no_poliza
	   and cod_endomov = '003';

	if _cnt > 0 then			                
		continue foreach;
	end if 	 	
				
	if _cod_formapag = '006' then	--Pago Voluntario	
	    
		call sp_cob33('001','001', _no_documento, _periodo_c, _fecha_actual)
		returning   _por_vencer,
					_exigible,
					_corriente,
					_monto_30,
					_monto_60,
					_monto_90,
					_saldo;	
		if _saldo = 0 or _cod_perpago = '007' then	                    --  Pto-5 Voluntario excepto sin saldo  , EMAIL:ASTANCIO 14/03/2018 tomar periocidad SEMESTRAL 
		else
		   continue foreach;
	   end if
	end if		

	 select nombre
	   into _nombre_ramo
	   from prdramo
	  where cod_ramo = _cod_ramo;	
	
	foreach
	  	SELECT cod_agente,
		       porc_partic_agt
	      INTO _cod_agente_anterior, --_cod_agente,
		       _porc_partic_agt
	      FROM emipoagt
	   	 WHERE no_poliza = _no_poliza
		 
		let _prima_sus_agt = 0; 
		let _prima_sus_agt = _prima_neta * _porc_partic_agt /100;
		
		let _flag = 0;
		--********  Unificacion de Agente *******
		call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;
		if _error <> 0 then
			return _error,'Error de Agente '||_cod_agente_anterior||' no Encontrado.','';
		end if 
		
		select nombre,
		       tipo_agente,
			   no_licencia,
			   estatus_licencia,
			   tipo_pago
		  into _nombre,
		       _tipo_agente,
			   _licencia,
			   _estatus_licencia,
			   _tipo_pago
		  from agtagent
		 where cod_agente = _cod_agente;

		IF _tipo_agente <> "A" then	      -- Solo Corredores
		    let _flag = 1;
		END IF

		IF _estatus_licencia <> "A" then  -- El Corredor Debe Estar Activo
		    let _flag = 1;
		END IF
		
		-- Informacion Necesaria para las Promotorias
		select sucursal_promotoria
		  into _suc_promotoria
		  from insagen
		 where codigo_agencia = _cod_agencia;

		select cod_vendedor
		  into _cod_vendedor
		  from parpromo
		 where cod_agente  = _cod_agente
		   and cod_agencia = _suc_promotoria
		   and cod_ramo	   = _cod_ramo;

		select nombre
		  into _nombre_vendedor
		  from agtvende
		 where cod_vendedor = _cod_vendedor;
		 
		select nombre
		  into _nombre_clte
		  from cliclien
		 where cod_cliente = _cod_contratante;		 
		 
		if _flag = 0 then
		
			insert into chqbono019(
			periodo, 
			cod_agente,
			no_documento,
			n_agente,
			prima_sus_nva,
			cod_vendedor,
			nombre_vendedor,
			cod_ramo,
			nombre_ramo,
			monto_bono,
			porc_bono,
			aplica, 
			date_added, 
			user_added,
			cod_subramo,
			cod_origen,
			nombre_cte,
			no_poliza,
			recupero
			)
			values(
			a_periodo, 
			_cod_agente, 
			_no_documento, 
			_nombre,
			_prima_sus_agt,
			_cod_vendedor,
			_nombre_vendedor,
			_cod_ramo,
			_nombre_ramo,
			0,0,0,
			current,
			a_usuario,
			_cod_subramo,
			_cod_origen, 
			_nombre_clte, 
			_no_poliza,
			0); 

			
			BEGIN
				ON EXCEPTION IN(-239,-268) 
					update chqbono019e 
					   set pri_sus_act = pri_sus_act + _prima_sus_agt, 
					       cantidad    = cantidad + 1  
					 where cod_agente  = _cod_agente 
					   and periodo     = a_periodo 
					   and cia         = a_compania; 
				END EXCEPTION 

				Insert into chqbono019e (cia,periodo,cod_agente,pri_sus_act,cantidad,bono,bono_queda,bono_recupero,n_agente,cod_ramo,nombre_ramo,licencia,tipo_pago,seleccionado,fecha_genera) 
				values (a_compania,a_periodo,_cod_agente,_prima_sus_agt,1,0,0,0,_nombre,_cod_ramo,_nombre_ramo,_licencia,_tipo_pago,0,current); 
				
			END					
			
		end if	
		
	end foreach
	
end foreach



foreach
	select cod_agente, pri_sus_act
	  into _cod_agente, _prima_neta
	  from chqbono019e
	 where cantidad >= 2         -- Pto-2 Minimo 2 Polizas por Agente
	   and pri_sus_act >= 1000   -- Pto-3 Suma 2 Polizas >= 1K
	   and periodo = a_periodo
	   
	   Let _monto_bono = 0;
	
	-- Unificar Tabla de Rangos Bono
	select monto
	  into _monto_bono  
	  from bonomae2 
	 where periodo[1,4]  = a_periodo[1,4] 
	   and cod_bono = '001' 
	   and round(_prima_neta,0) between desde and hasta; 
	
	if _monto_bono <> 0 then  

	 update chqbono019  
		set monto_bono = round((_monto_bono * round((prima_sus_nva/_prima_neta),4)),2),  
		    porc_bono  = round(round((prima_sus_nva/_prima_neta),4)*100,2), 
		    aplica = 1  
	  where cod_agente = _cod_agente
	    and periodo    = a_periodo;    
		
	 update chqbono019e    
	    set bono = _monto_bono, 
		    bono_queda = _monto_bono, 
			usuario = a_usuario, 
			fecha = _fecha_actual, 
			aplica = 1 			
	  where cod_agente = _cod_agente   
	    and periodo    = a_periodo;  
	  
	  end if
  
end foreach

{let _anio_ant = a_periodo[1,4] - 1;
let _periodo_ant      = _anio_ant||a_periodo[5,7];
CALL sp_che169(_periodo_ant) returning _error, _descripcion;
IF _error <> 0 THEN
	RETURN _error, 'Error al Generar Remesa de Recupero al periodo '||_periodo_ant||' . ','';
END IF}

return 0, 'Proceso de Bono Vida Indiv.(Nueva) Exitoso...'||_descripcion,a_periodo;

END PROCEDURE;