--*********************************************************
-- Procedimiento que genera reporte Bono VIDA INDIVIDUAL 
--********************************************************
-- Execute procedure sp_che164_rpt(2023)
-- Creado    : 28/09/2023 - Autor: Henry Giron

DROP PROCEDURE sp_che164_rpt;
CREATE PROCEDURE sp_che164_rpt(a_anio integer)
RETURNING	char(3)		as	CodVendedor,
			char(50)	as	Vendedor,
			char(5)		as	CodCorredor,
			char(50)	as	Corredor,
			char(5)		as	CodCorredor_agrupado,
			char(50)	as	Corredor_agrupado,
			char(3) 	as	CodRamo,
			char(50)	as	Ramo,
			char(3) 	as	CodSubramo,
			char(50)	as	Subramo,
			char(20) 	as	Poliza,
			date     	as	VigenciaInicial,
			date 		as	VigenciaFinal,
			dec(16,2) 	as	MontoCobrado,
			dec(16,2) 	as	MontoNetoCobrado,
			dec(9,4) 	as	PorcComision,
			dec(16,2) 	as	Comision,
			dec(16,2)	as	BonoCobranzaAA,
			dec(16,2)	as	Bono1Web,
			dec(16,2)	as	BonoRentabilidadAP,
			dec(16,2)	as	BonoRentabilidadAA,
			dec(16,2)	as	BonoRamosGeneralesAP,
			dec(16,2)	as	BonoRamosGeneralesAA,
			dec(16,2)	as	BonoVidaAA,			
			dec(16,2)	as	BonoPersistenciaAP,
char(7) as periodo			;


	  
define _cod_vendedor	char(3);
define _nombre_vendedor	char(50);
define _cod_agente   	char(5);
define _nombre_agente   char(50);
define _cod_agente_agrupado   	char(5);
define _nombre_agente_agrupado  char(50);
define _cod_ramo        char(3);  
define _nombre_ramo     char(50);
define _cod_subramo     char(3);  
define _periodo         char(7);  
define _periodoaa         char(7);  
define _nombre_subramo  char(50);
define _no_documento    char(20); 
define _vigencia_inic	date;
define _vigencia_final	date;
define _prima_cobrada   dec(16,2);
define _prima_neta_cobrada dec(16,2);
define _porc_bono	       dec(9,4);
define _monto_bono	       dec(16,2);
define _monto_bono_AA	   dec(16,2);
define _bono_cero 	       dec(16,2);
define _prima_sus_agt      dec(16,2);
define _pri_sus_act        dec(16,2);
define _error              smallint;
define _ano_ant			   smallint;

SET DEBUG FILE TO "sp_che164.trc";
TRACE ON;
drop table if exists tmp_bonovida;
CREATE TEMP TABLE tmp_bonovida(    
	CodVendedor				char(3),
	Vendedor				char(50),
	CodCorredor				char(5),
	Corredor 				char(50),
	CodCorredor_agrupado 	char(5),
	Corredor_agrupado 		char(50),
	CodRamo					char(3),
	Ramo					char(50),
	CodSubramo	  			char(3),
	Subramo					char(50),
	Poliza					char(20),
	VigenciaInicial			date,
	VigenciaFinal			date,
	MontoCobrado			dec(16,2),
	MontoNetoCobrado	 	dec(16,2),
	PorcComision			dec(9,4),
	Comision				dec(16,2),
	BonoCobranzaAA			dec(16,2),
	Bono1Web				dec(16,2),
	BonoRentabilidadAP		dec(16,2),
	BonoRentabilidadAA		dec(16,2),
	BonoRamosGeneralesAP	dec(16,2),
	BonoRamosGeneralesAA	dec(16,2),
	BonoVidaAA				dec(16,2),
	BonoPersistenciaAP		dec(16,2),
	periodo char(7)
	) WITH NO LOG;
CREATE INDEX i1_tmp_bonovida ON tmp_bonovida(Poliza);
CREATE INDEX i2_ttmp_bonovida ON tmp_bonovida(VigenciaFinal);

let _monto_bono_AA = 0.00;
let _periodo  = '';
let _prima_sus_agt  = 0.00;
let _monto_bono = 0.00;
let _porc_bono = 0.00;
let _bono_cero = 0.00;
let _pri_sus_act = 0.00;
let _error = 0;
let _ano_ant = 0;

-- Periodo Pasado
let _ano_ant = a_anio - 1;	

SET ISOLATION TO DIRTY READ;
--*****************************
-- Polizas Nuevas
--*****************************
foreach
	select 	a.periodo periodo,
		a.cod_vendedor CodVendedor,
		a.nombre_vendedor Vendedor,
		a.cod_agente CodCorredor,
		a.n_agente Corredor,
		a.Cod_Ramo CodRamo,
		a.nombre_ramo Ramo,
		s.Cod_subRamo CodSubramo,
		s.nombre Subramo,
		a.no_documento Poliza,
		p.Vigencia_Inic VigenciaInicial,
		p.Vigencia_Fin VigenciaFinal,
		a.prima_sus_nva MontoCobrado,
		a.prima_sus_nva MontoNetoCobrado,
		a.porc_bono PorcComision,
		e.bono Comision,
		e.pri_sus_act
	into _periodo,
	    _cod_vendedor,
		_nombre_vendedor,
		_cod_agente,
		_nombre_agente,
		_cod_ramo,
		_nombre_ramo,
		_cod_subramo,
		_nombre_subramo,
		_no_documento,
		_vigencia_inic,
		_vigencia_final,
		_prima_sus_agt,
		_prima_neta_cobrada ,
		_porc_bono,
		_monto_bono,
        _pri_sus_act		
	from chqbono019 a
	inner join emipoliza p on p.no_documento = a.no_documento
	inner join chqbono019e e on a.periodo = e.periodo and a.cod_agente = e.cod_agente and a.Cod_Ramo = e.Cod_Ramo
	inner join prdsubra s on a.Cod_Ramo = s.Cod_Ramo and a.Cod_subRamo = s.Cod_subRamo
	where a.monto_bono > 0
	and year(a.date_added) = a_anio and e.periodo[1,4] = a_anio
	and a.aplica = 1
	
	      let _monto_bono_AA = 0;			  
		  let _periodoAA = _ano_ant || _periodo[5,7]; 
		  
		select sum(r.monto_bono)
		  into _monto_bono_AA
		  from emipomae p, chqbono019 r
		 where p.no_poliza = r.no_poliza 
		   and r.periodo = _periodoAA
		   and r.no_documento = _no_documento;	
		   --and r.aplica = 1;	  
	
	    select sum(a.monto),sum(a.prima_neta)
	      into _prima_cobrada, _prima_neta_cobrada
	      from cobredet a
	     where a.periodo >= _periodo
		   and a.tipo_mov in ('P','N')
		   and a.actualizado  = 1 		
		   and a.doc_remesa   = _no_documento;   
		   
	-- Unificar Tabla de Rangos Bono
		{select monto
		  into _monto_bono  
		  from bonomae2 
		 where periodo[1,4]  = _periodo[1,4] 
		   and cod_bono = '001' 
		   and round(_pri_sus_act,0) between desde and hasta; }
		   
		   
		--********  Unificacion de Agente *******
		call sp_che168(_cod_agente) returning _error,_cod_agente_agrupado;
		
		SELECT nombre
		  INTO _nombre_agente_agrupado
		  FROM agtagent
		 WHERE cod_agente = _cod_agente_agrupado;	
		 
		 if _monto_bono_AA is null then 
		 let _monto_bono_AA = 0;
		 end if
		
		BEGIN
		ON EXCEPTION IN(-239,-268) 

		END EXCEPTION 
			insert into tmp_bonovida(
			CodVendedor,
			Vendedor,
			CodCorredor,
			Corredor,
			CodCorredor_agrupado,
			Corredor_agrupado,
			CodRamo,
			Ramo,
			CodSubramo,
			Subramo,
			Poliza,
			VigenciaInicial,
			VigenciaFinal,
			MontoCobrado,
			MontoNetoCobrado,
			PorcComision,
			Comision,
			BonoCobranzaAA	,
			Bono1Web,
			BonoRentabilidadAP,
			BonoRentabilidadAA,
			BonoRamosGeneralesAP,
			BonoRamosGeneralesAA,
			BonoVidaAA,
			BonoPersistenciaAP,	
			periodo
			)
			values(
			_cod_vendedor,
			_nombre_vendedor,
			_cod_agente,
			_nombre_agente,
			_cod_agente_agrupado,
			_nombre_agente_agrupado,
			_cod_ramo,
			_nombre_ramo,
			_cod_subramo,
			_nombre_subramo,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_prima_sus_agt,  --_prima_cobrada,
			_prima_neta_cobrada ,
			_porc_bono,
			_monto_bono,0,0,0,0,0,0,
			_monto_bono_AA,	0,
			_periodo); 
		END			
	
end foreach

foreach
	select CodVendedor,
			Vendedor,
			CodCorredor,
			Corredor,
			CodCorredor_agrupado,
			Corredor_agrupado,
			CodRamo,
			Ramo,
			CodSubramo,
			Subramo,
			Poliza,
			VigenciaInicial,
			VigenciaFinal,
			MontoCobrado,
			MontoNetoCobrado,
			PorcComision,
			Comision,
			periodo
	  into _cod_vendedor,
			_nombre_vendedor,
			_cod_agente,
			_nombre_agente,
			_cod_agente_agrupado,
			_nombre_agente_agrupado,
			_cod_ramo,
			_nombre_ramo,
			_cod_subramo,
			_nombre_subramo,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_prima_cobrada,
			_prima_neta_cobrada ,
			_porc_bono,
			_monto_bono,
			_periodo
	  from tmp_bonovida		   
	  

	  

RETURN _cod_vendedor,
			_nombre_vendedor,
			_cod_agente,
			_nombre_agente,
			_cod_agente_agrupado,
			_nombre_agente_agrupado,
			_cod_ramo,
			_nombre_ramo,
			_cod_subramo,
			_nombre_subramo,
			_no_documento,
			_vigencia_inic,
			_vigencia_final,
			_prima_cobrada,
			_prima_neta_cobrada ,
			_porc_bono,
			_monto_bono,
			_bono_cero,
			_bono_cero,
			_bono_cero,			
			_bono_cero,
			_bono_cero,
			_bono_cero,
			_monto_bono_AA,	
			_bono_cero,
			_periodo
		   WITH RESUME;
end foreach



END PROCEDURE;