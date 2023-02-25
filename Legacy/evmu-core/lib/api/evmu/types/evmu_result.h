#ifndef EVMU_RESULT_H
#define EVMU_RESULT_H

#include "evmu_context.h"

#ifdef __cplusplus
extern "C" {
#endif



#ifndef EVMU_RESULT_ERROR_ASSERT
#   define EVMU_RESULT_ERROR_ASSERT
#endif

#ifndef EVMU_RESULT_ASSERT
#   ifdef EVMU_RESULT_ERROR_ASSERT
#       define EVMU_RESULT_ASSERT(b, s) EVMU_ASSERT(b, s)
#   else
#       define EVMU_RESULT_ASSERT(b, s)
#   endif
#endif

#ifndef EVMU_RESULT_ERROR_LOG
#   define EVMU_RESULT_ERROR_LOG
#endif


#define EVMU_VA_ARGS(...) \
    __VA_ARGS__

#define EVMU_CTX_DEV(pCtx) \
    EVMU_VA_ARGS(pCtx, NULL)

#define EVMU_DEV_CTX(pDev) \
    evmuDeviceContext(pDev), pDev

#define EVMU_RESULT_CTX_FOLD(pCtx, HANDLER, ...) \
    EVMU_RESULT_##HANDLER(pCtx, NULL, __VA_ARGS__)


#ifndef EVMU_RESULT_LOG
#   ifdef EVMU_RESULT_ERROR_LOG
#       define EVMU_RESULT_LOG(pCtx, file, func, line, exp, ...)     \
            do {                                                     \
                if(exp) evmuLogWrite_(pCtx,                          \
                               file, func, line,                     \
                               EVMU_LOG_LEVEL_ERROR, __VA_ARGS__);   \
            } while(0)
#   else
#       define EVMU_RESULT_LOG(pCtx, file, func, line, exp, ...)
#   endif
#endif

#ifndef EVMU_RESULT_ERROR_LOG_LEVEL
#   define EVMU_RESULT_ERROR_LOG_LEVEL EVMU_LOG_LEVEL_ERROR
#endif

#ifndef EVMU_RESULT_SET_LAST_ERROR
#   ifdef EVMU_RESULT_CONTEXT_TRACK_LAST_ERROR
#       define EVMU_RESULT_SET_LAST_ERROR(pCtx, pDevice, result, level, pFile, pFunc, line, ...) \
            evmuContextUpdateLastError_(pCtx, pDevice, result, level, pFile, pFunc, line, __VA_ARGS__)
#   else
#       define EVMU_RESULT_SET_LAST_ERROR(pCtx, pDevice, result, level, pFile, pFunc, line, pFormat, ...)
#   endif
#endif

#define EVMU_RESULT_CLEAR_LAST_ERROR(pCtx) \
    EVMU_RESULT_SET_LAST_ERROR(pCtx, NULL, EVMU_RESULT_SUCCESS, EVMU_LOG_LEVEL_VERBOSE, NULL, NULL, 0, NULL)

#define EVMU_RESULT_ERROR_CAT(error) EVMU_APPEND_SUFFIX(EVMU_RESULT_ERROR, error)

#define EVMU_RESULT_HANDLER(pCtx, pDev, exp, errorResult, ...)              \
    evmuResultHandler(pCtx, pDev, (EVMUBool)(exp), EVMU_RESULT_ERROR_CAT(errorResult),   \
                      EVMU_FILE, EVMU_FUNC, EVMU_LINE,                \
                      __VA_ARGS__)

#define EVMU_RESULT_RETURN(pCtx, pDev, exp, errorResult, ...)                     \
    do {                                                                    \
        if(!evmuResultHandler(pCtx, pDev, (EVMUBool)(exp), EVMU_RESULT_ERROR_CAT(errorResult),   \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,              \
                              __VA_ARGS__))                                 \
            return EVMU_RESULT_ERROR_CAT(errorResult);                                             \
    } while(0)


#define ELYSIAN_RESULT_ASSIGN_0(pCtx, pDev, exp, errorResult) \
    do {                                                                       \
        if(!evmuResultHandler(pCtx, pDev, exp, EVMU_RESULT_ERROR_CAT(errorResult),                          \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,                 \
                              NULL))                                            \
            result = EVMU_RESULT_ERROR_CAT(errorResult);                                              \
        }                                                                      \
    } while(0)

#define EVMU_RESULT_ASSIGN_N(pCtx, pDev, exp, errorResult, ...)                     \
    do {                                                                       \
        if(!evmuResultHandler(pCtx, pDev, exp, EVMU_RESULT_ERROR_CAT(errorResult),                          \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,                 \
                              __VA_ARGS__))                                    \
            result = EVMU_RESULT_ERROR_CAT(errorResult);                                              \
        }                                                                      \
    } while(0)

#define EVMU_RESULT_ASSIGN(...)                   \
    EVMU_VA_OVERLOAD_CALL(EVMU_RESULT_ASSIGN,     \
                          EVMU_VA_OVERLOAD_SUFFIXER_0_N,  \
                          __VA_ARGS__)

#define EVMU_RESULT_ASSIGN_GOTO_1(pCtx, pDev, exp, errorResult, label)            \
    do {                                                                       \
        if(!evmuResultHandler(pCtx, pDev, (exp), errorResult,    \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,                 \
                              NULL)) {                                  \
            result = errorResult;                                              \
            goto label;                                                  \
        }                                                                      \
    } while(0)


#define EVMU_RESULT_ASSIGN_GOTO_2(pCtx, pDev, exp, errorResult, label, pFormat)            \
    do {                                                                       \
        if(!evmuResultHandler(pCtx, pDev, (exp), errorResult,    \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,                 \
                              pFormat)) {                                  \
            result = errorResult;                                              \
            goto label;                                    \
        }                                                                      \
    } while(0)

#define EVMU_RESULT_ASSIGN_GOTO_N(pCtx, pDev, exp, errorResult, label, ...)            \
    do {                                                                       \
        if(!evmuResultHandler(pCtx, pDev, (exp), errorResult,    \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,                 \
                              __VA_ARGS__)) {                                  \
            result = errorResult;                                              \
            goto label;                                    \
        }                                                                      \
    } while(0)

#define EVMU_RESULT_ASSIGN_GOTO(pCtx, pDev, exp, errorResult, ...)                      \
    EVMU_VA_OVERLOAD_CALL(EVMU_RESULT_ASSIGN_GOTO,               \
                          EVMU_VA_OVERLOAD_SUFFIXER_ARGC,    \
                          __VA_ARGS__)(pCtx, pDev, (exp), EVMU_RESULT_ERROR_CAT(errorResult),__VA_ARGS__)

#define EVMU_RESULT_VALIDATE_ARG_2(pCtx, pDev, argName, exp)                      \
    do {                                                                    \
        if(!evmuResultHandler(pCtx, pDev, exp, EVMU_RESULT_ERROR_INVALID_ARG,     \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,              \
                              "INVALID_ARG[%s]: %s (Value: %d)",            \
                              EVMU_STRINGIFY(argName), EVMU_STRINGIFY((exp)), argName))                     \
            return EVMU_RESULT_ERROR_INVALID_ARG;                           \
    } while(0)


#define EVMU_RESULT_VALIDATE_ARG_1(pCtx, pDev, argName)                            \
    EVMU_RESULT_VALIDATE_ARG_2(pCtx, pDev, argName, argName!=0)

#define EVMU_RESULT_VALIDATE_ARG(pCtx, pDev, ...)                       \
    EVMU_VA_OVERLOAD_CALL(EVMU_RESULT_VALIDATE_ARG,         \
                          EVMU_VA_OVERLOAD_SUFFIXER_ARGC,   \
                          __VA_ARGS__) (pCtx, pDev, __VA_ARGS__)

#define EVMU_RESULT_VALIDATE_HANDLE_3(pCtx, pDev, argName, exp)                   \
    do {                                                                    \
        if(!evmuResultHandler(pCtx, pDev, exp, EVMU_RESULT_ERROR_INVALID_ARG,     \
                              EVMU_FILE, EVMU_FUNC, EVMU_LINE,              \
                              "INVALID_HANDLE[%s]: %s (Value: %p)",         \
                              #argName, #exp, argName))                     \
            return EVMU_RESULT_ERROR_INVALID_HANDLE;                        \
    } while(0)


#define EVMU_RESULT_VALIDATE_HANDLE_2(pCtx, handle) \
    EVMU_RESULT_VALIDATE_HANDLE_3(pCtx, handle, handle != 0)

#define EVMU_RESULT_VALIDATE_HANDLE_1(pCtx) \
    EVMU_RESULT_VALIDATE_HANDLE_2(pCtx, pCtx)


#define EVMU_RESULT_VALIDATE_HANDLE(...)                   \
    EVMU_VA_OVERLOAD_CALL(EVMU_RESULT_VALIDATE_HANDLE,     \
                          EVMU_VA_OVERLOAD_SUFFIXER_ARGC,  \
                          __VA_ARGS__)(__VA_ARGS__)


#if 0
static inline EVMU_RESULT evmuErrorHandler(const EVMUContext*     pCtx,
                                            const EVMUDevice*      pDev,  
                                            const char*            pFile,
                                            const char*            pFunc,
                                            uint64_t               line,
                                            EVMU_RESULT            result,
                                            const char*            pFormat, //handle NULL gracefully, just log enum name
                                           ...)
{
    
    
}

#endif

#if 0
static inline EVMUBool evmuResultHandler(const EVMUContext*     pCtx,
                                         const EVMUDevice*      pDevice,
                                         EVMUBool               exp,
                                         EVMU_RESULT            result,
                                         const char*            pFile,
                                         const char*            pFunc,
                                         uint64_t               line,
                                         const char*            pFormat, //handle NULL gracefully, just log enum name
                                        ...)
{
    if(!exp) {
        EVMU_VA_SNPRINTF(pFormat);
        EVMU_RESULT_LOG(pCtx,
                        pFile, pFunc, line,
                        EVMU_RESULT_ERROR_LOG_LEVEL, buffer);
        EVMU_RESULT_ASSERT(exp, buffer);
        EVMU_RESULT_SET_LAST_ERROR(pCtx, pDevice, result, EVMU_RESULT_ERROR_LOG_LEVEL, pFile, pFunc, line, buffer);
    } else {
        EVMU_RESULT_CLEAR_LAST_ERROR(pCtx);
    }

    return exp;
}

#endif


#ifdef __cplusplus
}
#endif

#endif // EVMU_RESULT_H
