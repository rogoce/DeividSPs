-- Reporte de Detalle de Auxiliar de cuentas
-- Creado    : 17/01/2011 
-- Autor : Henry Giron
drop procedure sp_sac218a;
create procedure "informix".sp_sac218a(
a_ano 	  char(4), 
a_mes 	  smallint,
a_nivel	  smallint,
a_db	  char(18),
a_cta_gts char(12),
a_ccosto  char(3)
)

define _cuenta		char(12);
define _debito		dec(16,2);
define _credito		dec(16,2);
define _saldo		dec(16,2);
define _pres_monto	dec(16,2);
define _nombre		char(50);
define _referencia	char(20);

define _saldo_ant	dec(16,2);
define _saldo_act	dec(16,2);

define _mes_ant		smallint;
define _ano_ant		char(4);
define _ano_int		smallint;
define _recibe		char(1);
define _nivel		char(1);
define _auxiliar	char(5);
define _name_aux	char(50);
define _ter_cedula	char(20);


define _det_tipo	char(2);
define _det_ccosto	char(3);

define _imp_delmes	dec(16,2);
define _porc_delmes dec(16,2);
define _saldo_almes dec(16,2);
define _pres_almes	dec(16,2);
define _imp_almes	dec(16,2);
define _porc_almes	dec(16,2);
define _pres_alanio dec(16,2);
define _imp_alanio	dec(16,2);
define _porc_alanio	dec(16,2);

define _debito_ant	    dec(16,2);
define _credito_ant	    dec(16,2);
define _saldo_anterior	dec(16,2);
define _pres_monto_ant	dec(16,2);

DEFINE _hay,_periodo   	 INTEGER;
DEFINE _ene 	 		 DECIMAL(16,2);  
DEFINE _feb 	 		 DECIMAL(16,2);
DEFINE _mar 	 		 DECIMAL(16,2);  
DEFINE _abr 	 		 DECIMAL(16,2);  
DEFINE _may 	 		 DECIMAL(16,2);  
DEFINE _jun 	 		 DECIMAL(16,2);
DEFINE _jul 	 		 DECIMAL(16,2);  
DEFINE _ago 	 		 DECIMAL(16,2);  
DEFINE _sep 	 		 DECIMAL(16,2);  
DEFINE _oct 	 		 DECIMAL(16,2);
DEFINE _nov 	 		 DECIMAL(16,2);  
DEFINE _dic 	 		 DECIMAL(16,2);  
DEFINE _total    		 DECIMAL(16,2); 
define _aux_debito		 dec(16,2);
define _aux_credito		 dec(16,2);
define _aux_saldo		 dec(16,2);

define _rubro			smallint;
define _tipo			char(12);
define _nombre_tipo		char(50);
define _nombre_rubro	char(50);
define _orden_rubro		smallint;	

--set debug file to "sp_sac218a.trc";
--trace on;

LET _hay   = 0;
LET _periodo = 0;
LET _ene   = 0;	
LET _feb   = 0;	
LET _mar   = 0;	
LET _abr   = 0;	
LET _may   = 0;	
LET _jun   = 0;	
LET _jul   = 0;	
LET _ago   = 0;	
LET _sep   = 0;	
LET _oct   = 0;	
LET _nov   = 0;	
LET _dic   = 0;	
LET _total = 0;

let _ano_int = a_ano;
let _mes_ant = a_mes;

if a_mes = 1 then
	let _ano_int = _ano_int - 1;
	let _mes_ant = 14;
else
	let _mes_ant = _mes_ant - 1;
end if

let _ano_ant = _ano_int;

if a_nivel = 1 then
	let _recibe = "*";
	let _nivel  = "1";
else
	let _recibe = "S";
	let _nivel  = "*";
end if
let _porc_alanio = 0;
let _porc_almes = 0;
let _det_tipo   = "*";
let _det_ccosto	= "*";
--  let _det_ccosto	= trim(a_ccosto);

if a_db = "sac" then

	foreach
	 select	cta_cuenta,
	        referencia,
			cta_nombre
	   into	_cuenta,
			_referencia,
			_nombre
	   from sac:cglcuentas
	  where cta_nivel  matches _nivel
		and cta_recibe matches _recibe
		and cta_cuenta like (a_cta_gts)
		and cta_auxiliar = "S"
	  order by 1

		foreach
			select sldet_periodo,
			       sum(sldet_debtop),
				   sum(sldet_cretop)
			  into _periodo,
			       _debito,
				   _credito
			  from sac:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = a_ano
			   group by 1

			if _debito is null then
				let _debito = 0;
			end if

			if _credito is null then
				let _credito = 0;
			end if

			if _debito     = 0 and 
			   _credito    = 0 then
				continue foreach;
			end if

			let _saldo     = _debito + _credito;

			let _saldo_ant = 0;

			select sum(sldet_saldop)
			  into _saldo_ant
			  from sac:cglsaldodet
			 where sldet_cuenta  = _cuenta
			   and sldet_ano     = _ano_ant
		       and sldet_periodo = _mes_ant;
--			   and sldet_ccosto  matches _det_ccosto;

			if _saldo_ant is null then
				let _saldo_ant = 0;
			end if

			select cod_tipo 
			  into _tipo 
			  from sac:cglcuentas 
			 where cta_cuenta = _cuenta; 

			   if  _tipo is null then
				   let _rubro = 0;
				   let _tipo  = _cuenta;			
				   let _nombre_tipo  = _nombre;		
				   let _nombre_rubro = "";	
				   let _orden_rubro  = 0;		
			 else

				select rubro,nombre 
				  into _rubro,_nombre_tipo 
				  from sac:cgltigas
				 where cod_tipo = _tipo; 

					if _rubro = '1' then
						let _nombre_rubro = "TOTAL DE GASTOS DE PERSONAL";
					end if
					if _rubro = '2' then
						let _nombre_rubro = "TOTAL DE GASTOS ADMINISTRATIVOS";
					end if
					if _rubro = '3' then
						let _nombre_rubro = "TOTAL DE GASTOS COMERCIALES";
					end if
					if _rubro = '4' then
						let _nombre_rubro = "TOTAL DE GASTOS PUBLICIDAD";
					end if
					if _rubro = '5' then
						let _nombre_rubro = "TOTAL GASTOS GENERALES";
					end if

			end if

			insert into tmp_gtsprea(
			cuenta,
			nombre,
			debito,
			credito,
			saldo,
			saldo_ant,
			rubro,		
			tipo,		
			nombre_tipo,
			nombre_rubro
			)
			values(
			_cuenta,		
			_nombre,		
			_debito,		
			_credito,
			_saldo,			
			_saldo_ant,
			_rubro,		
			_tipo,		
			_nombre_tipo,
			_nombre_rubro					
			);

			foreach
			  select sld1_tercero,sum(sld1_debitos),sum(sld1_creditos)
			    into _auxiliar,_aux_debito,_aux_credito
				from sac:cglsaldoaux1
			   where sld1_cuenta  = _cuenta
				 and sld1_ano     = a_ano
				 and sld1_periodo = _periodo
				group by 1
				order by 1

				    let _aux_saldo = 0;
					if _aux_debito is null then
						let _aux_debito = 0;
					end if
					if _aux_credito is null then
						let _aux_credito = 0;
					end if
					if _aux_debito    = 0 and 
					   _aux_credito   = 0 then
						continue foreach;
					end if
					let _aux_saldo = _aux_debito + _aux_credito;

					let _hay = 0;
					select count(*)
					  into _hay
					  from tmp_auxsac218a
					 where cuenta = _cuenta 
					   and auxiliar = _auxiliar;

					if _hay = 0 then
						LET _ene   = 0;	
						LET _feb   = 0;	
						LET _mar   = 0;	
						LET _abr   = 0;	
						LET _may   = 0;	
						LET _jun   = 0;	
						LET _jul   = 0;	
						LET _ago   = 0;	
						LET _sep   = 0;	
						LET _oct   = 0;	
						LET _nov   = 0;	
						LET _dic   = 0;	
						LET _total = 0;
						LET _name_aux = "";

						SELECT trim(ter_descripcion),ter_cedula 
						  INTO _name_aux, _ter_cedula 
						  FROM sac:cglterceros
						 WHERE ter_codigo = _auxiliar;

						insert into tmp_auxsac218a(cuenta,auxiliar,name_aux,ene,feb,mar,abr,may,jun,jul,ago,sep,oct,nov,dic,total,ter_cedula,rubro,tipo)
						values (_cuenta,_auxiliar,_name_aux,_ene,_feb,_mar,_abr,_may,_jun,_jul,_ago,_sep,_oct,_nov,_dic,_total,_ter_cedula,_rubro,_tipo);
					end if 

					if _periodo = 1 then
						update tmp_auxsac218a
						   set ene         = ene + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 2 then	 
						update tmp_auxsac218a
						   set feb         = feb + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 3 then
						update tmp_auxsac218a
						   set mar         = mar + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 4 then
						update tmp_auxsac218a
						   set abr         = abr + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 5 then
						update tmp_auxsac218a
						   set may         = may + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 6 then
						update tmp_auxsac218a
						   set jun         = jun + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 7 then
						update tmp_auxsac218a
						   set jul         = jul + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 8 then
						update tmp_auxsac218a
						   set ago         = ago + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 9 then
						update tmp_auxsac218a
						   set sep         = sep + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 10 then
						update tmp_auxsac218a
						   set oct         = oct + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 11 then
						update tmp_auxsac218a
						   set nov         = nov + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					elif _periodo = 12 then
						update tmp_auxsac218a
						   set dic         = dic + _aux_saldo , total = total + _aux_saldo
                         where cuenta = _cuenta 
					       and auxiliar = _auxiliar; 
					end if 


			end foreach
		end foreach
	end foreach

end if
--trace off;
    
end procedure