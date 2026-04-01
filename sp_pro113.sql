-- Polizas Renovadas con Saldo
-- 
-- Creado    : 10/03/2003 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 31/03/2003 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_prod_sp_pro113_dw1 - DEIVID, S.A.

drop procedure sp_pro113;

create procedure sp_pro113(a_compania CHAR(3), a_agencia char(3), a_periodo char(7))
returning char(20),
          date,
		  date,
		  char(100),
		  dec(16,2),
		  dec(16,2),
		  char(3),
		  char(50),
		  char(50);

define _mes_contable    char(2);
define _ano_contable    char(4);
define _saldo           dec(16,2);
define _por_vencer      dec(16,2);
define _exigible        dec(16,2);
define _corriente       dec(16,2);
define _monto_30        dec(16,2);
define _monto_60        dec(16,2);
define _monto_90        dec(16,2);
define a_fecha			date;
define _cod_contratante char(10);
define _vigencia_inic	date;
define _vigencia_final	date;
define _nombre_cliente  char(100);
define _cod_ramo        char(3);
define _nombre_ramo     char(50);
define _no_documento    char(20);
define _prima_bruta     dec(16,2);
define _no_poliza       char(10);
define _nombre_compania char(50);
 
set isolation to dirty read;

let _nombre_compania = sp_sis01(a_compania);

let a_fecha = today;

{
let _ano_contable = year(a_fecha);

if month(a_fecha) < 10 then
	let _mes_contable = '0' || month(a_fecha);
else
	let _mes_contable = month(a_fecha);
end if

let _periodo = _ano_contable || '-' || _mes_contable;
}

foreach			 
 select no_documento,
        no_poliza,
		cod_contratante,
		vigencia_inic,
		vigencia_final,
		cod_ramo
   into _no_documento,
        _no_poliza,
		_cod_contratante,
		_vigencia_inic,
		_vigencia_final,
		_cod_ramo
   from emipomae
  where periodo     = a_periodo
    and actualizado = 1
	and nueva_renov = "R"

	select prima_bruta
	  into _prima_bruta
	  from endedmae
	 where no_poliza = _no_poliza
	   and no_endoso = "00000";

--	call sp_par78c(
	call sp_cob33(
		 a_compania,
		 a_agencia,	
		 _no_documento,
		 a_periodo,
		 a_fecha
		 ) returning _por_vencer,       
    				 _exigible,         
    				 _corriente,        
    				 _monto_30,         
    				 _monto_60,         
    				 _monto_90,
    				 _saldo;    


	if _saldo > _prima_bruta then

		select nombre
		  into _nombre_cliente
		  from cliclien
		 where cod_cliente = _cod_contratante;
		 
		select nombre
		  into _nombre_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

		 return _no_documento,
		        _vigencia_inic,
		        _vigencia_final,
		        _nombre_cliente,
		        _prima_bruta,
		        _saldo,
				_cod_ramo,
				_nombre_ramo,
				_nombre_compania
		        with resume; 		

	end if


end foreach

end procedure
