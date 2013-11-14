
import numpy as np
import pylab as pl
import matplotlib.pyplot as plt
from sklearn import linear_model
from sklearn import cross_validation
from sklearn.metrics import accuracy_score, f1_score, confusion_matrix
from sklearn import lda
import time

'''
author: Wu Zhenzhou
I use pyplot and scikit-learn for this project. Refer to scikit-learn api for more details
Reference: scikit-learn.org
'''


def load_X_y(dir_path = '../hw1-data/q2-data/'):
    
    with open(dir_path+"X.txt", 'r') as X_file:
        X = []
        line = X_file.readline()
        while line != "":
            row = map(float, line.split())
            X.append(row)
            line = X_file.readline()
        X = np.asarray(X)
                
    with open(dir_path+'y.txt', 'r') as y_file: 
        y = []
        line = y_file.readline()
        while line != "":
            ele = map(float, line.split())
            y += ele
            line = y_file.readline()
        y = np.asarray(y)         
    
    return X, y

def plot_graph(x_label, y_label, title, legend, save_path, axis='tight', *args):
    #plt.yscale('symlog')
    line = plt.plot(*args)
    plt.legend(line, legend)
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    plt.title(title)
    plt.axis(axis)
    plt.savefig(save_path)
    plt.close()
    
def qn_2a(X, y):
    
    print 'start qn 2a'
    print 'starts generating graphs ...'
    
    for ele_x, ele_y in zip(X, y):
        if ele_y == 0:
            plt.plot(ele_x[0], ele_x[1], 'rx')
        else:
            plt.plot(ele_x[0], ele_x[1], 'bx')
    
    plt.savefig('plots_X_y.png')
    plt.close()
    
    print 'end qn 2a'

def qn_2b(X, y):
    
    print 'start qn 2b'
    print 'starts generating graphs ...'
    
    t1 = time.clock()
    
    length = y.shape[0]
    
    clf = linear_model.LogisticRegression()
    
    folds =  np.asarray(xrange(2,length+1))

    train_kf_accu = []
    train_kf_f1 = []
    test_kf_accu = []
    test_kf_f1 = []
    fold = []
    for k in folds:
        kf = cross_validation.KFold(length, n_folds=k, indices=False)
        train_accu = 0
        train_f1 = 0
        test_accu =0
        test_f1 = 0
        
        if length % k != 0:
            continue
        
        for train, test in kf:
            X_train, X_test, y_train, y_test = X[train], X[test], y[train], y[test]
            clf.fit(X_train, y_train)
            y_train_pred = clf.predict(X_train)
            y_test_pred = clf.predict(X_test)
            train_accu += accuracy_score(y_train, y_train_pred)
            test_accu += accuracy_score(y_test, y_test_pred)
            train_f1 += f1_score(y_train, y_train_pred)
            test_f1 += f1_score(y_test, y_test_pred)

        fold.append(k) 
        train_kf_accu.append(train_accu/k)
        test_kf_accu.append(test_accu/k)
        train_kf_f1.append(train_f1/k)
        test_kf_f1.append(test_f1/k)
        
    print 'kfolds:', fold
    print 'train_set accuracy:', train_kf_accu
    print 'test_set accuracy:', test_kf_accu
    print 'train_set f1', train_kf_f1
    print 'test_set f1', test_kf_f1

    plot_graph('kfold', 'accuracy', 'accuracy vs kfolds', ['train_accuracy', 'test_accuracy'],
               '2b_accu_kfold.png', 'tight', fold, train_kf_accu, fold, test_kf_accu)
    plot_graph('kfold', 'F1', 'F1 vs kfolds', ['train_F1', 'test_F1'],
               '2b_accu_f1.png', 'tight', fold, train_kf_f1, fold, test_kf_f1)

    t2 = time.clock()

    print 'end qn 2b, time taken ', t2 - t1
    
            

def qn_2c(X, y):
    print 'start qn 2c'
    print 'starts generating graphs ...'
    
    t1 = time.clock()
    
    clf = linear_model.LogisticRegression()
     
    length = y.shape[0]
    n_folds = 100
    kf = cross_validation.KFold(length, n_folds=n_folds, indices=False)
 
    FN_arr = []
    FP_arr = []
    boundaries = 0.2 * np.asanyarray(xrange(1,25))
    for decision_boundary in boundaries:
         
        FN_total = 0
        FP_total = 0
        pred = []
        for train, test in kf:
         
            X_train, X_test, y_train, y_test = X[train], X[test], y[train], y[test]
            clf.fit(X_train, y_train)
            clf.intercept_ = decision_boundary

            y_test_pred = clf.predict(X_test)
            
            test_cm = confusion_matrix(y_test, y_test_pred)
            total = float(np.sum(test_cm))
            
            TN = test_cm[0][0] / total
            FP = test_cm[0][1] / total
            FN = test_cm[1][0] / total
            TP = test_cm[1][1] / total
             
             
            FN_total += FN
            FP_total += FP         
        
        FN_ave = FN_total / n_folds
        FP_ave = FP_total / n_folds
        FN_arr.append(FN_ave)
        FP_arr.append(FP_ave)
     
     
    print 'FN', FN_arr
    print 'FP', FP_arr
    #plt.twiny(0.2 * np.array(xrange(1,200)))
    
    fig = plt.figure()
    ax = fig.add_subplot(111)
    ax.plot(FP_arr, FN_arr, label = 'ROC')
    ax.plot([0,0.128], [0.128,0], label = "best classification line")
    #ax.plot(time, Rn, '-', label = 'Rn')
    ax2 = ax.twiny()
    #ax2.axis([boundaries[0], boundaries[-1], 0, 0])
    #ax2.plot(time, temp, '-r', label = 'temp')
    ax.legend(loc=0)
    ax.grid()
    ax.set_xlabel("FP rate")
    ax.set_ylabel("FN rate")
    ax2.set_xlabel("Boundary Distance")
    plt.savefig('roc.png')
    plt.close()
    #plot_graph("FP rate", "FN rate", "ROC curve", ["ROC"], 
    #"roc.png", "tight", FN_arr, FP_arr)
     
    t2 = time.clock()

    print 'end qn 2c, time taken ', t2 - t1
    

def qn_2d(X, y):
    
    #length = y.shape[0]
    #n_folds = 100
    #kf = cross_validation.KFold(length, n_folds=n_folds, indices=False)
    print 'start qn 2d'
    print 'starts generating graphs ...'
    
    t1 = time.clock()
    
    length = y.shape[0]
    
    clf = lda.LDA()    
    folds =  np.asarray(xrange(2,length+1))

    train_kf_accu = []
    train_kf_f1 = []
    test_kf_accu = []
    test_kf_f1 = []
    fold = []
    for k in folds:
        kf = cross_validation.KFold(length, n_folds=k, indices=False)
        train_accu = 0
        train_f1 = 0
        test_accu =0
        test_f1 = 0
        
        if length % k != 0:
            continue
        
        for train, test in kf:
            X_train, X_test, y_train, y_test = X[train], X[test], y[train], y[test]
            clf.fit(X_train, y_train)
            y_train_pred = clf.predict(X_train)
            y_test_pred = clf.predict(X_test)
            train_accu += accuracy_score(y_train, y_train_pred)
            test_accu += accuracy_score(y_test, y_test_pred)
            train_f1 += f1_score(y_train, y_train_pred)
            test_f1 += f1_score(y_test, y_test_pred)

        fold.append(k) 
        train_kf_accu.append(train_accu/k)
        test_kf_accu.append(test_accu/k)
        train_kf_f1.append(train_f1/k)
        test_kf_f1.append(test_f1/k)
        
    print 'kfolds:', fold
    print 'train_set accuracy:', train_kf_accu
    print 'test_set accuracy:', test_kf_accu
    print 'train_set f1', train_kf_f1
    print 'test_set f1', test_kf_f1

    plot_graph('kfold', 'accuracy', 'accuracy vs kfolds', ['train_accuracy', 'test_accuracy'],
               '2d_accu_kfold.png', 'tight', fold, train_kf_accu, fold, test_kf_accu)
    plot_graph('kfold', 'F1', 'F1 vs kfolds', ['train_F1', 'test_F1'],
               '2d_accu_f1.png', 'tight', fold, train_kf_f1, fold, test_kf_f1)

    t2 = time.clock()

    print 'end qn 2d, time taken ', t2 - t1
    
if __name__ == '__main__':
    
    print 'uncomment each function below to view results for each question'
    
    X, y = load_X_y()
    qn_2a(X, y)
    qn_2b(X,y)
    qn_2c(X, y)
    qn_2d(X,y)
    
    
    