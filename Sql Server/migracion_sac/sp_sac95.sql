--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*--
--*  CIERRRE ANUAL
--*  Juan Plata  - ABRIL 2007
--*  Ref. Power Builder

drop procedure sp_sac95;
create procedure sp_sac95(v_compania char(03),v_usuario char(10))

returning	smallint,
			char(150);

begin
----
define wdatabase        char(18);
define w_periodos       char(2);
define w_par_mesfiscal  char(2);
define w_par_anofiscal  char(4);
define w_par_ingreso1   char(12);
define w_par_ingreso2   char(12);
define w_par_resultado  char(12);
define mes_fiscal       char(2);
define ano_fiscal       char(4);
define nvo_ano          char(4);
---variables de la tabla cgltrx1
define w1_notrx       integer;
define w1_tipo        char(2);
define w1_comprobante char(15);
define w1_fecha       date;
define w1_concepto    char(3);
define w1_ccosto      char(3);
define w1_descrip     char(50);
define w1_monto       decimal(15,2);
define w1_moneda      char(2);
define w1_debito      decimal(15,2);
define w1_credito     decimal(15,2);
define w1_status      char(1);
define w1_origen      char(3);
define w1_usuario     char(15);
define w1_fechacap    datetime year to second;
---variables de la tabla cgltrx2
define w2_notrx   integer;
define w2_tipo    char(2);
define w2_linea   integer;
define w2_cuenta  char(12);
define w2_ccosto  char(3);
define w2_debito  decimal(15,2);
define w2_credito decimal(15,2);
define w2_actlzdo char(1);
---variables de la tabla cgltrx2
define w3_notrx integer;
define w3_tipo char(2);
define w3_lineatrx2 integer;
define w3_linea integer;
define w3_cuenta char(12);
define w3_auxiliar char(5);
define w3_debito decimal(15,2);
define w3_credito decimal(15,2);
define w3_actlzdo char(1);
---variables de la tabla cglcuenta
define wcta_nivel      char(1);
define wcta_tippartida char(1);
define wcta_recibe     char(1);
define wcta_histmes    char(1);
define wcta_histano    char(1);
define wcta_auxiliar   char(1);
define wcta_saldoprom  char(1);
define wcta_moneda     char(2);


define ws_sld_tipo char(2);
define ws_sld_cuenta char(12);
define ws_sld_ccosto char(3);
define ws_sld_ano char(4);
define ws_sld_incioano char(18);

define ws_sldet_tipo char(2);
define ws_sldet_cuenta char(12);
define ws_sldet_ccosto char(3);
define ws_sldet_ano char(4);
define ws_sldet_periodo smallint;
define ws_sldet_debtop decimal(15,2);
define ws_sldet_cretop decimal(15,2);
define ws_sldet_saldop decimal(15,2);

--define ws_sld_tipo char(2);
--define ws_sld_cuenta char(12);
define ws_sld_tercero char(5);
--define ws_sld_ano char(4);
--define ws_sld_incioano decimal(15,2);

define ws_sld1_tipo char(2);
define ws_sld1_cuenta char(12);
define ws_sld1_tercero char(5);
define ws_sld1_ano char(4);
define ws_sld1_periodo smallint;
define ws_sld1_debitos decimal(15,2);
define ws_sld1_creditos decimal(15,2);
define ws_sld1_saldo decimal(15,2);

-------------------------------------
define w_status1      char(1);
define mensaje_error  char(150);
define l_codigo       smallint;
define ls_auxiliar   char(1);
-- 1 error
-- 0 satisfactorio

define wper_ano        char(4);
define wper_mes        char(2);
define wper_status     char(1);
define pos1            smallint;
define pos2            smallint;
define indice          smallint;
define i               smallint;
define j               smallint;
define k               smallint;
define idx             smallint;
define nivel1          smallint;
define work_cta        char(12);
define work_ano        char(04);
define total_db_det    decimal(15,2);
define total_cr_det    decimal(15,2);
define ls_cuenta       char(12);
define pdebitos        decimal(15,2);
define pcreditos       decimal(15,2);
define psaldo          decimal(15,2);
define pdebitos2       decimal(15,2);
define pcreditos2      decimal(15,2);
define psaldo2         decimal(15,2);
define pdebitos3       decimal(15,2);
define pcreditos3      decimal(15,2);
define psaldo3         decimal(15,2);
define ls_cuenta3      char(12);
define ls_auxiliar3    char(5);
define pdebitos4       decimal(15,2);
define pcreditos4      decimal(15,2);
define psaldo4         decimal(15,2);
define wsldet_periodo  smallint;
define ws_periodo  smallint;
define ws_periodo1  smallint;
define wsld1_periodo  smallint;
define no_reg_mes             integer;
define ll_ciclo   integer;
define ld_fecha_inicio date;
define ld_fecha_final  date;
define pant_ano integer;
define pant_mes integer;

define mes       smallint;
define ano       smallint;
define ld_saldo  decimal(15,2);
define mesa      char(02);
define anoa      char(04);
define saldo_inicial        decimal (17,2);

define resultado  decimal(15,2);
define debito     decimal(15,2);
define credito    decimal(15,2);
define cre        decimal(15,2);
define deb        decimal(15,2);
define tot_db     decimal(15,2);
define tot_cr     decimal(15,2);
define tipo_trx   char(02);
define tipo_comp  char(03);
define descrip    char(30);
define fecha1      date;
define linea_trx2   integer;
define debito1      decimal(15,2);
define credito1     decimal(15,2);
define linea       integer;  -- falto declararla . henry
define linea2       integer;
define v_variable,_cnt   integer;

--set debug file to "sp_sac95.trc";
--trace on;

let l_codigo = 0;
let mensaje_error = "No existen registros por actualizar";
let resultado = 0.00;
let debito    = 0.00;
let credito   = 0.00;
let tot_db    = 0.00;
let tot_cr    = 0.00;
let cre       = 0.00;
let deb       = 0.00;

select par_periodos,
	   par_mesfiscal,
	   par_anofiscal,
	   par_ingreso1,
	   par_ingreso2,
	   par_resultado
  into w_periodos,
	   w_par_mesfiscal,
	   w_par_anofiscal,
	   w_par_ingreso1,
	   w_par_ingreso2,
	   w_par_resultado
  from cglparam;   
   
if w_par_mesfiscal <> (w_periodos + 2) then
    let l_codigo = 1;
    let mensaje_error = "No ha llegado al Ultimo Periodo";
end if

--SELECT * FROM cglperiodo
select count(*)
  into v_variable
  from cglperiodo
 where per_ano     = w_par_anofiscal
   and per_status1 = "C";
   
--if status <> 0 then
if v_variable <> 1 then
  let l_codigo = 1;
  let mensaje_error = "No existe periodo para asiento de cierre";
end if 

--select * from cglperiodo
select count(*) 
  into v_variable 
  from cglperiodo
 where per_ano     = w_par_anofiscal
   and per_mes     = "13"
   and per_status  = "C";    -- se adiciono el ; no lo tenia
   
--IF STATUS <> 0 THEN
if v_variable <> 1 then
  let l_codigo = 1;
  let mensaje_error = "No se ha cerrado el periodo 13 .....";
end if

select con_codigo,
	   con_descrip
  into tipo_comp,
	   descrip
  from cglconcepto
 where con_status = "C";

select per_final
  into fecha1
  from cglperiodo
 where per_ano     = w_par_anofiscal
   and per_mes     = w_par_mesfiscal
   and per_status1 = "C";

--let l_codigo = 1;

if l_codigo = 0 then

	let l_codigo = 1;
	let mensaje_error = "No existen registros por actualizar";

	foreach
		select sld_tipo
		  into tipo_trx
		  from cglsaldoctrl
		 group by sld_tipo
		 order by sld_tipo
		
		select param_valor
		  into no_reg_mes
		  from seguridad:sigman25
		 where param_comp     = v_compania
		   and param_apl_id   = "CGL"
		   and param_apl_vers = "03"
		   and param_codigo   = "par_notrx";

		if no_reg_mes is null or
		   no_reg_mes = " " then
		   let no_reg_mes = 1;
		end if

		let no_reg_mes = no_reg_mes + 1;
		let linea = 0;

		insert into cgltrx1
		values(	no_reg_mes,
				tipo_trx,
				"CIERRE",
				fecha1,
				tipo_comp,
				v_compania,
				descrip,
				0.00,
				"00",
				0.00,
				0.00,
				"I",
				"CGL",
				v_usuario,
				current year to second );
	--0.00, "r","cgl",v_usuario, current year to second );

		let l_codigo = 0;
		let mensaje_error = "Comprobante actualizado satisfactoriamente";			

		foreach
			select sldet_tipo,
				   sldet_cuenta,
				   sldet_ccosto,
				   sldet_ano,
				   sldet_periodo,
				   sldet_debtop,
				   sldet_cretop,
				   sldet_saldop
			  into ws_sldet_tipo,
				   ws_sldet_cuenta,
				   ws_sldet_ccosto,
				   ws_sldet_ano,
				   ws_sldet_periodo,
				   ws_sldet_debtop,
				   ws_sldet_cretop,
				   ws_sldet_saldop
			  from cglsaldodet		
			 where sldet_tipo    = tipo_trx
			   and sldet_cuenta >= w_par_ingreso1
			   and sldet_cuenta <= w_par_ingreso2
			   and sldet_ano     = w_par_anofiscal
			   and sldet_periodo = "14" 
			 order by sldet_periodo,sldet_cuenta,sldet_ccosto
		   
			select cta_nivel,
				   cta_tippartida,
				   cta_recibe,
				   cta_histmes,
				   cta_histano,
				   cta_saldoprom,
				   cta_moneda,
				   cta_auxiliar 
			  into wcta_nivel,
				   wcta_tippartida,
				   wcta_recibe,
				   wcta_histmes,
				   wcta_histano,
				   wcta_saldoprom,
				   wcta_moneda,
				   wcta_auxiliar
			  from cglcuentas
			 where cta_cuenta = ws_sldet_cuenta;

			select count(*)
			  into v_variable
			  from cglcuentas
			 where cta_cuenta = ws_sldet_cuenta;

	--            IF STATUS <> 0 THEN
			if v_variable <> 1 then
				continue foreach; 
			end if

			if wcta_recibe = "N" then
			   continue foreach;
			end if
				
			let credito   = 0.00;
			let debito    = 0.00;
			let resultado = resultado + ws_sldet_saldop;

			if ws_sldet_saldop > 0 then
			   let debito  = 0;
			   let credito = ws_sldet_saldop;
			   let cre     = cre + credito;
			   let tot_cr  = tot_cr + ws_sldet_saldop;
			   let tot_db  = tot_db + ws_sldet_saldop;
			end if

			if ws_sldet_saldop < 0 then
			   let credito = 0;
			   let debito  = ws_sldet_saldop * (-1);
			   let tot_cr  = tot_cr + (ws_sldet_saldop * (-1));
			   let tot_db  = tot_db + (ws_sldet_saldop * (-1));
			end if
			let linea = linea + 1;

			if debito = 0 and credito = 0 then
			   continue foreach;
			end if

			insert into cgltrx2
			values(	no_reg_mes,
					tipo_trx,
					linea,
					ws_sldet_cuenta,
					ws_sldet_ccosto,
					debito,
					credito,
					" ");

			if debito = 0 then
			   let debito  = credito;
			   let credito = 0;
			else
			   let credito = debito;
			   let debito  = 0;
			end if

			let linea = linea + 1;
				 
			insert into cgltrx2
			values(	no_reg_mes,
					tipo_trx,
					linea,
					w_par_resultado,
					ws_sldet_ccosto,
					debito,
					credito," ");
				
			if wcta_auxiliar = "S" then

				select count(*)
				  into _cnt
				  from cgltrx3
				 where trx3_notrx   = no_reg_mes
				   and trx3_tipo    = tipo_trx
				   and trx3_cuenta  = ws_sldet_cuenta;

				if _cnt <> 0 then
					continue foreach;
				end if

				let linea2     = 0;	   -- se coloco para que tome la cuenta desde 1 cuando inicia el ciclo. Henry

				foreach
					select sld1_debitos,
						   sld1_creditos,
						   sld1_saldo,
						   sld1_periodo,
						   sld1_tercero
					  into ws_sld1_debitos,
						   ws_sld1_creditos,
						   ws_sld1_saldo,
						   ws_sld1_periodo,
						   ws_sld1_tercero
					  from cglsaldoaux1 
					 where sld1_tipo    = tipo_trx
					   and sld1_cuenta  = ws_sldet_cuenta
					   and sld1_ano     = w_par_anofiscal
					   and sld1_periodo = "14"

					let linea_trx2 = linea - 1;   -- relacion de detalle con terceros. henry

					if ws_sld1_saldo is null then
					   let ws_sld1_saldo = 0;
					end if

					if ws_sld1_saldo = 0 then
					   let debito1  = 0;
					   let credito1 = 0;
					end if

					if ws_sld1_saldo > 0 then
					   let debito1  = 0;
					   let credito1 = ws_sld1_saldo;
					end if
			
					if ws_sld1_saldo < 0 then
					   let debito1  = ws_sld1_saldo * (-1);
					   let credito1 = 0; 
					end if

					let linea2 = linea2 + 1;

					insert into cgltrx3(
							trx3_notrx,
							trx3_tipo,
							trx3_lineatrx2,
							trx3_linea,
							trx3_cuenta,
							trx3_auxiliar,
							trx3_debito,
							trx3_credito,
							trx3_actlzdo,
							trx3_referencia)
					values(	no_reg_mes,
							tipo_trx,
							linea_trx2,
							linea2,
							ws_sldet_cuenta,
							ws_sld1_tercero,
							debito1,credito1,
							" ",
							" ");
				end foreach
			end if
		end foreach	
		
		if resultado > 0.00 then
		   let debito  = resultado;
		   let credito = 0.00;
		   let cre     = cre - debito;
		end if
	 
		if resultado < 0.00 then
		   let credito = resultado * (-1);
		   let cre     = cre + credito;
		   let debito  = 0.00;
		end if
		
		let linea = linea + 1;

		update cgltrx1
		   set trx1_monto   = tot_cr,
			   trx1_debito  = tot_db,
			   trx1_credito = tot_cr
		 where trx1_notrx   = no_reg_mes;		
	end foreach		

	if l_codigo = 0 then
		update seguridad:sigman25
		   set param_valor    = no_reg_mes
		 where param_comp     = v_compania
		   and param_apl_id   = "CGL"
		   and param_apl_vers = "03"
		   and param_codigo   = "par_notrx";
	end if
end if	 

return l_codigo, mensaje_error;
--trace off;
end
end procedure;